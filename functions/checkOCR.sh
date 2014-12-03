#! /bin/bash
result=$(pdffonts "$1" | wc -l)
if [ "$result" -eq 2 ]
then
     exit 1
fi

exit 0
