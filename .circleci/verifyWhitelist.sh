#!/usr/bin/env bash

if [ -z "${BASE_REV}" ]; then
  BASE="origin/master"
else
  BASE="${BASE_REV}"
fi

CHANGED_FILES=`git diff --name-only $BASE...HEAD`

CHANGED_FILE_LIST=($(echo "$CHANGED_FILES" | sed 's/:/ /g'))
WHITELIST=($(cat .circleci/whitelist.txt | sed 's/:/ /g'))

beginswith() { case $1 in "$2"*) true;; *) false;; esac; }

endswith() { case $1 in *"$2") true;; *) false;; esac; }

INDEX=1
for file in "${CHANGED_FILE_LIST[@]}"
do
    MATCHED=0

    for item in "${WHITELIST[@]}"
    do
        if endswith "$item" / && beginswith "$file" "$item"; then
            MATCHED=1
            break
        elif [ "$file" == "$item" ]; then
            MATCHED=1
            break
        fi
    done

    if [ "$MATCHED" == '0' ]; then
        RESULT[INDEX]=$file
        INDEX=$((INDEX+1)) 
    fi

done

if [ ${#RESULT[@]} -ne 0 ]; then
    echo "We only allow the modification of these files:\n${WHITELIST[@]}\n\nThe files you modified:\n${RESULT[@]}"
    echo "\n--------------------\n"
    echo "我们只允许你修改以下文件:\n${WHITELIST[@]}\n\n但是你修改了:\n${RESULT[@]}"
    exit 1
fi
