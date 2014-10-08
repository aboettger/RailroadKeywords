#!/bin/bash
# createTxtFile "$pdf_path" "$pdf_dirname" "$pdf_filename"

# Absolute path to this script, e.g. /home/user/bin/foo.sh
script=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
script_path=$(dirname "$script")

cfg_log_level=$(look log_level "$script_path"/../main.cfg | cut -d '=' -f 2-)
. "$script_path/../libraries/logging.sh" "$cfg_log_level"

pdf_path="$1"
pdf_dirname="$2"
pdf_filename="$3"

spaces=$(python -c 'print u"\u0001\u000C\u0009\u00A0\u2004\u2005\u2006\u2009\u200A\u200B".encode("utf8")')
double_quotes=$(python -c 'print u"\u201c\u201d\u201e\u201f\u0022".encode("utf8")')
# pdftotext "$pdf_path" "$pdf_dirname/$pdf_filename.txt"
# if [ $? -gt 0 ]; then 
#   logError "Fehler in der Verarbeitung, lösche txt-Dateien"
#   rm "$pdf_dirname/$pdf_filename.human-readable.txt"
#   rm "$pdf_dirname/$pdf_filename.txt"
#   exit 1;
# fi

if [ ! -f "$pdf_dirname/$pdf_filename.human-readable.txt" ] || [ -f "$pdf_dirname/txt_created_by_pdftotext" ]; then
  logInfo "Verwende \"pdf2txt\""
  pdf2txt.py -o "$pdf_dirname/$pdf_filename.human-readable.txt" "$pdf_path"
  if [ $? -gt 0 ]; then 
    logError "Fehler in der Verarbeitung durch \"pdf2txt\", lösche txt-Dateien"
    if [ -f "$pdf_dirname/$pdf_filename.human-readable.txt" ]; then
      rm "$pdf_dirname/$pdf_filename.human-readable.txt"
    fi
    if [ -f "$pdf_dirname/$pdf_filename.txt" ]; then
      rm "$pdf_dirname/$pdf_filename.txt"
    fi
    
    logInfo "Neuer Versuch unter Verwendung von \"pdftotext\"…"

    pdftotext "$pdf_path" "$pdf_dirname/$pdf_filename.human-readable.txt"
    if [ $? -gt 0 ]; then 
      logError "Fehler in der Verarbeitung, lösche txt-Dateien"
      if [ -f "$pdf_dirname/$pdf_filename.human-readable.txt" ]; then
        rm "$pdf_dirname/$pdf_filename.human-readable.txt"
      fi
      if [ -f "$pdf_dirname/$pdf_filename.txt" ]; then
        rm "$pdf_dirname/$pdf_filename.txt"
      fi
      exit 1;
    fi
    touch "$pdf_dirname/txt_created_by_pdftotext"
  else
    if [ -f "$pdf_dirname/txt_created_by_pdftotext" ]; then
      rm "$pdf_dirname/txt_created_by_pdftotext"
    fi
  fi

  if [ ! -f "$pdf_dirname/txt_created_by_pdftotext" ]; then
    logInfo "Erzwinge neu schreiben von \"$pdf_dirname/$pdf_filename.md5\"."
    md5_new_Pdf=$(md5sum "$pdf_path"  | gawk  -F ' ' '{print $1}')
    echo "$md5_new_Pdf" > "$pdf_dirname/$pdf_filename.md5"
  fi
fi

temp_file_1=$(tempfile)
temp_file_2=$(tempfile)
# temp_file_3=$(tempfile)
# temp_file_4=$(tempfile)

logInfo "Schreibe \"$pdf_filename.txt\" neu."

# !!!!! Runde Klammern dürfen nicht angefasst werden, das gibt Probleme mit Bauarten und Achsfolgen !!!!!
# Ständiger Wechsel zwischen temp_file_1 und temp_file_2
sed -E ':a;N;$!ba;s/([a-z])\-\n([a-z])/\1\2/g' "$pdf_dirname/$pdf_filename.human-readable.txt" > "$temp_file_1"
# Namen die durch Zeilenumbrüche getrennt sind zusammenführen, z.B. "Richard\nTrevithick" --> "Richard Trevithick"
sed -E ':a;N;$!ba;s/([a-z])\n([A-Z])/\1 \2/g' "$temp_file_1" > "$temp_file_2"
sed -E ':a;N;$!ba;s/([0-9])\n([0-9])/\1 ~ \2/g' "$temp_file_2" > "$temp_file_1"
sed -E ':a;N;$!ba;s/([A-Z])\n([0-9])/\1 \2/g' "$temp_file_1" > "$temp_file_2"
sed -E ':a;N;$!ba;s/([a-zA-Z])(\-)\n([A-Z])/\1\2\3/g' "$temp_file_2" > "$temp_file_1"
sed -e ':a;N;$!ba;s/\n/ \n /g' "$temp_file_1" | sed -e 's/['"$spaces"']/ /g' | sed -e 's/['"$double_quotes"']//g' | sed -e 's/\*[[:space:]]/ \* /g' | sed -e 's/)/ )/g' | sed -e 's/(/( /g' | sed -e 's/\.\./ /g' | sed -e 's/\.[[:space:]]/ \. /g' | sed -e 's/\![[:space:]]/ \! /g' | sed -e 's/\?[[:space:]]/ \? /g' | sed -e 's/\,[[:space:]]/ \, /g' | sed -e 's/\:[[:space:]]/ \: /g' | sed -e 's/\;[[:space:]]/ \; /g' | sed -E 's/\-/ - /g' | sed -E 's/([0-9])\-(.)/\1 - \2/g' | sed -E 's/[[:space:]]{2,}/ /g' | sed -E 's/([[:space:]]BR)([0-9])/\1 \2/g' > "$temp_file_2"
sed -E 's/[[:space:]][a-z]{3,}/ ~/g' "$temp_file_2" > "$temp_file_1"
sed -E 's/\(cid\:[0-9]{1,3}\)//g' "$temp_file_1" > "$temp_file_2"
# Move the temporary file 
cp "$temp_file_1" "$pdf_dirname/$pdf_filename.txt"

rm "$temp_file_1"
rm "$temp_file_2"
# rm "$temp_file_3"
# rm "$temp_file_4"


exit 0
