#!/bin/bash
# createTxtFile "$pdf_path" "$pdf_dirname" "$pdf_filename"

# Absolute path to this script, e.g. /home/user/bin/foo.sh
script=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
script_path=$(dirname "$script")

cfg_log_level=$(look log_level "$script_path"/../main.cfg | cut -d '=' -f 2-)
. "$script_path/../libraries/logging.sh" "$cfg_log_level"

cfg_category_separator=$(look category_separator "$script_path"/../main.cfg | cut -d '=' -f 2-)

pattern_case="$1"
txt_path="$2"
isTest="$3"

pattern=$("$script_path/../functions/getPattern.sh" "$pattern_case")
# prefix=$(sed -e '/^#/d' "$pattern_case" | grep 'prefix=' | gawk  -F 'prefix=' '{print $2}')
# if [ ! -z "$prefix" ]; then
#   prefix=$(echo "$prefix" | sed -e 's/(/\\(/g' | sed -e 's/)/\\)/g' | sed -e 's/{/\\{/g' | sed -e 's/}/\\}/g' | sed -e 's/|/\\|/g')
# fi

pattern_delete=$(sed -e '/^#/d' "$pattern_case" | grep 'pattern_delete=' | gawk  -F 'pattern_delete=' '{print $2}')
if [ ! -z "$pattern_delete" ]; then
  pattern_delete=$(sed -e 's/(/\\(/g' <<< "$pattern_delete" | sed -e 's/)/\\)/g' | sed -e 's/{/\\{/g' | sed -e 's/}/\\}/g' | sed -e 's/|/\\|/g')
fi

# logInfo "pattern $pattern_case"
# timea=$(($(date +%s%N)/1000000))

echo "$pattern" | { while read -r line; do
  # line=$(echo "$line" | sed -e 's/(/\\(/g' | sed -e 's/)/\\)/g')
  # sed -e "s/$line/\2/" "$txt_path"
  if [[ $isTest == "1" ]]; then
    result=$(grep -oaE "^$line\$" "$txt_path" | sed -e 's/^ *//' | sed -e 's/ *$//')
  else
    result=$(grep -oaE "$line" "$txt_path" | sed -e 's/^ *//' | sed -e 's/ *$//')
  fi


  if [ ! -z "$pattern_delete" ]; then
    result=$(sed -e "s/$pattern_delete//g" <<< "$result")
  fi

  if [ ! -z "$prefix" ]; then
    result=$(echo "$result" | sed -E "s/^(.*)\$/$prefix\1/g")
  fi

  if [[ $result != "" ]]; then
    category=$(look category "$pattern_case" | cut -d '=' -f 2-)
    if [[ $isTest == "0" ]] && [[ $cfg_log_level == "4" ]]; then
      log_result=$(sort <<< "$result" | uniq | sed -e 's/^/\\t/g')
      logDebug "Kategorie: $category (\"$pattern_case\")\n$log_result"
    fi
    while read -r keyword; do
      if [[ $keyword != "" ]]; then
        # Da ich bei der Erstellung der txt-Dateien einen Bindestrich "-"
        # durch " - " ersetze, muss ich das hier wieder rückgängig machen.
        keyword=${keyword// - /-}
        if [[ $cfg_category_separator == "" ]] || [[ $category == "" ]]; then
          echo "$keyword"
        else
          echo "$category$cfg_category_separator$keyword"
        fi
      fi
    done <<< "$result"
  fi
done }
# timeb=$(($(date +%s%N)/1000000))
# logInfo "---> $((timeb - timea)) ms"

exit 0
