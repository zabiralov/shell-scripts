#!/usr/bin/env bash

# Simple script for rename ebook files related to metadata

set -o pipefail

#set -x

bold=$(tput bold)
normal=$(tput sgr0)

function get-metadata {
    local metadata
    metadata=$(exiftool "$1")
    echo "${metadata}"
}

function get-language {
    local language
    language=$(echo "$1" | awk -F' : ' '/^Language\s+:/ {print $2}' | grep -Eo '^[[:alpha:]]{2}')
    echo -n "${language,,}"
}

function get-year {
    local year
    year=$(echo "$1" | awk -F' : ' '/^Date\s+:/ {print $2}' | grep -Eo '^[[:digit:]]{4}')
    echo -n "${year}"
}

function get-creator {
    local creator
    creator=$(echo "$1" | awk -F' : ' '/^Creator\s+:/ {print $2}' | grep -Eo '^[[:alpha:]]+\b')
    echo -n "${creator,,}"
}

function get-title {
    local title
    title=$(echo "$1" | awk -F' : ' '/^Title\s+:/ {print $2}' | sed 's/[\ \.:,_]/-/g ; s/--/-/g ; s/-$//')
    echo -n "${title,,}"
}

for book in *.epub
do
    metadata=$(get-metadata "${book}")
    nlanguage=$(get-language "${metadata}")
    nyear=$(get-year "${metadata}")
    ncreator=$(get-creator "${metadata}")
    ntitle=$(get-title "${metadata}")

    ext="${book##*.}"
    nname="${nlanguage}-${nyear}-${ncreator}-${ntitle}.${ext}"
    echo -e "${book} >>>> ${bold}${nname}${normal}"

    if [[ "$1" = '-r' ]]
    then
        mv "${book}" "${nname}"
    fi
done
