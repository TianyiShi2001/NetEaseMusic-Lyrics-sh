#!/usr/bin/env bash

USAGE="USAGE: ${0##*/} music_id/search_keyword [output_file] "

[[ $# -lt 1 || $1 == '-h' || $1 == '--help' ]] && echo $USAGE && exit 1

fetch_lyric() {
    curl http://music.163.com/api/song/media?id=$1 | jq -r '.lyric'
}

re='^[0-9]+$'
if [[ $1 =~ $re ]]; then
    ID=$1
    OUT=${2:-_lyric.lrc}
    fetch_lyric $ID >${OUT}
else
    QUERY=$1
    RESULT=$(curl -G --data-urlencode "keywords=$QUERY" https://musicapi.leanapp.cn/search | jq '.result.songs[].id')
    for id in $RESULT; do
        LYRICS=$(fetch_lyric $id)
        echo "$LYRICS" | less
        echo "Save this one? (y/n)"
        read -rsn1 </dev/tty
        if [[ $REPLY == 'y' ]]; then
            echo "Save to? ($1.lrc)"
            read -r </dev/tty
            if [[ -z $REPLY ]]; then
                OUT=$1.lrc
            else
                OUT=$REPLY
            fi
            echo "$LYRICS" >$OUT
            exit 0
        fi
    done
fi
