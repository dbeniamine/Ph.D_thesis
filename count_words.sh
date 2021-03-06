#!/bin/bash
WORDS=('Thus' 'Therefore' 'Thereby' 'Hence' 'Consequently' 'As a result' 'Yet' 'Still' 'But' 'However' 'Nevertheless' 'While' 'Although' 'Despite' 'Anyway' 'Furthermore' 'Moreover'  'Additionally' 'Indeed')

if [ -z "$1" ]
then
    FILES=$(find tex -name "*.tex")
else
    FILES=$@
fi

for file in $FILES
do
    echo "$file"
    for word in "${WORDS[@]}"
    do
        res=$(grep -v "^%" $file | grep -ci "\<$word\>")
        echo -e "\t$word: $res"
    done
done
