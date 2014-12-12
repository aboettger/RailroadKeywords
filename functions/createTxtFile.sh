#!/bin/bash
# createTxtFile "$pdf_path" "$pdf_dirname" "$pdf_filename"

# Absolute path to this script, e.g. /home/user/bin/foo.sh
script=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
script_path=$(dirname "$script")

cfg_log_level=$(look log_level "$script_path"/../main.cfg | cut -d '=' -f 2-)
. "$script_path/../libraries/logging.sh" "$cfg_log_level"

pdf_path="$1"

pdf_dirname=$(dirname "$pdf_path")
pdf_filename=$(basename "$pdf_path")
pdf_filename="${pdf_filename%.*}"

spaces=$(python -c 'print u"\u0001\u000C\u0009\u00A0\u2004\u2005\u2006\u2009\u200A\u200B".encode("utf8")')
double_quotes=$(python -c 'print u"\u201c\u201d\u201e\u201f\u0022".encode("utf8")')
# pdftotext "$pdf_path" "$pdf_dirname/$pdf_filename.compressed.txt"
# if [ $? -gt 0 ]; then 
#   logError "Fehler in der Verarbeitung, lösche txt-Dateien"
#   rm "$pdf_dirname/$pdf_filename.human-readable.txt"
#   rm "$pdf_dirname/$pdf_filename.compressed.txt"
#   exit 1;
# fi

if [ ! -f "$pdf_dirname/$pdf_filename.human-readable.txt" ] || [ -f "$pdf_dirname/txt_created_by_pdftotext" ]; then
  
  "$script_path/checkOCR.sh" "$pdf_path"
  if [ $? -eq 1 ]; then
    logInfo "Starte OCR"
    convert -depth 8 "$pdf_path" "$pdf_dirname/$pdf_filename.tiff"
    tesseract  "$pdf_dirname/$pdf_filename.tiff" "$pdf_dirname/$pdf_filename.human-readable" -l deu
    touch "$pdf_dirname/spellcheck_check_required"
    if [ $? -eq 1 ]; then
      touch "$pdf_dirname/$pdf_filename.human-readable.txt"
      touch "$pdf_dirname/$pdf_filename.compressed.txt"
    fi
    rm "$pdf_dirname"/*.tiff
  else
  
    logInfo "Verwende \"pdf2txt\""
    pdf2txt.py -o "$pdf_dirname/$pdf_filename.human-readable.txt" "$pdf_path"
    if [ $? -gt 0 ]; then 
      logError "Fehler in der Verarbeitung durch \"pdf2txt\", lösche txt-Dateien"
      if [ -f "$pdf_dirname/$pdf_filename.human-readable.txt" ]; then
        rm "$pdf_dirname/$pdf_filename.human-readable.txt"
      fi
      if [ -f "$pdf_dirname/$pdf_filename.compressed.txt" ]; then
        rm "$pdf_dirname/$pdf_filename.compressed.txt"
      fi
      
      logInfo "Neuer Versuch unter Verwendung von \"pdftotext\"…"

      pdftotext "$pdf_path" "$pdf_dirname/$pdf_filename.human-readable.txt"
      if [ $? -gt 0 ]; then 
        logError "Fehler in der Verarbeitung, lösche txt-Dateien"
        if [ -f "$pdf_dirname/$pdf_filename.human-readable.txt" ]; then
          rm "$pdf_dirname/$pdf_filename.human-readable.txt"
        fi
        if [ -f "$pdf_dirname/$pdf_filename.compressed.txt" ]; then
          rm "$pdf_dirname/$pdf_filename.compressed.txt"
        fi
        exit 1;
      fi
      touch "$pdf_dirname/txt_created_by_pdftotext"
    else
      if [ -f "$pdf_dirname/txt_created_by_pdftotext" ]; then
        rm "$pdf_dirname/txt_created_by_pdftotext"
      fi
    fi
  fi
  
  if [ ! -f "$pdf_dirname/txt_created_by_pdftotext" ]; then
    logInfo "Erzwinge neu schreiben von \"$pdf_dirname/$pdf_filename.md5\"."
    md5_new_Pdf=$(md5sum "$pdf_path"  | gawk  -F ' ' '{print $1}')
    echo "$md5_new_Pdf" > "$pdf_dirname/$pdf_filename.md5"
  fi
fi

logInfo "Schreibe \"$pdf_dirname/$pdf_filename.compressed.txt\" neu."
cp "$pdf_dirname/$pdf_filename.human-readable.txt" "$pdf_dirname/$pdf_filename.compressed.txt"

sed -Ei ':a;N;$!ba;s/([a-z])[[:space:]]*\-[[:space:]]*\n([a-z])/\1\2/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei ':a;N;$!ba;s/\n/ \n /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei ':a;N;$!ba;s/([a-z])[[:space:]]*\n[[:space:]]*([A-Z])/\1 \2/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei ':a;N;$!ba;s/([0-9])[[:space:]]*\n[[:space:]]*([0-9])/\1 ~ \2/' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei ':a;N;$!ba;s/([A-Z])[[:space:]]*\n[[:space:]]*([0-9])/\1 \2/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei ':a;N;$!ba;s/([a-zA-Z])(\-)[[:space:]]*\n[[:space:]]*([A-Z])/\1\2\3/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\(cid\:[0-9]{1,3}\)//g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/['"$spaces"']/ /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/['"$double_quotes"']//g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\*[[:space:]]/ \* /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\)/ )/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\(/( /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\.\./ /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\.[[:space:]]/ \. /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\![[:space:]]/ \! /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\?[[:space:]]/ \? /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\,/ \, /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\:[[:space:]]/ \: /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\;[[:space:]]/ \; /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/\-/ - /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/([0-9])\-(.)/\1 - \2/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/[[:space:]]{2,}/ /g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/([[:space:]]BR)([0-9])/\1 \2/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/[[:space:]][a-z]{3,}/ ~/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/ﬂ/fl/g' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei 's/ﬁ/fi/g' "$pdf_dirname/$pdf_filename.compressed.txt"

# Müll entfernen

sed -Ei '/^[[:space:]]*\-*[[:space:]]*$/d' "$pdf_dirname/$pdf_filename.compressed.txt"
sed -Ei '/^[[:space:]]*[~0-9A-Za-z][[:space:]]*$/d' "$pdf_dirname/$pdf_filename.compressed.txt"

exit 0
