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

category=$(look category "$pattern_case" | cut -d '=' -f 2-)

pattern=$("$script_path/../functions/getPattern.sh" "$pattern_case")
# prefix=$(sed -e '/^#/d' "$pattern_case" | grep 'prefix=' | gawk  -F 'prefix=' '{print $2}')
# if [ ! -z "$prefix" ]; then
#   prefix=$(echo "$prefix" | sed -e 's/(/\\(/g' | sed -e 's/)/\\)/g' | sed -e 's/{/\\{/g' | sed -e 's/}/\\}/g' | sed -e 's/|/\\|/g')
# fi

# time_complete_a=$(($(date +%s%N)/1000000))

pattern_delete=$(sed -e '/^#/d' "$pattern_case" | grep 'pattern_delete=' | gawk  -F 'pattern_delete=' '{print $2}')
if [ ! -z "$pattern_delete" ]; then
  pattern_delete=$(sed -e 's/(/\\(/g' <<< "$pattern_delete" | sed -e 's/)/\\)/g' | sed -e 's/{/\\{/g' | sed -e 's/}/\\}/g' | sed -e 's/|/\\|/g')
fi

# time_complete_b=$(($(date +%s%N)/1000000))
# logDebug "pattern_delete in $script: $((time_complete_b - time_complete_a)) ms"

while read -r line; do
  # line=$(echo "$line" | sed -e 's/(/\\(/g' | sed -e 's/)/\\)/g')
  # sed -e "s/$line/\2/" "$txt_path"
  
  # time_complete_a=$(($(date +%s%N)/1000000))
  
  if [[ $isTest == "1" ]]; then
    result=$(grep -oaE "^$line\$" "$txt_path" | sed -e 's/^ *//' | sed -e 's/ *$//')
  else
    result=$(grep -oaE "$line" "$txt_path" | sed -e 's/^ *//' | sed -e 's/ *$//' | sort | uniq)
  fi
  
  # time_complete_b=$(($(date +%s%N)/1000000))
  # logDebug "result in $script: $((time_complete_b - time_complete_a)) ms"

  if [ ! -z "$pattern_delete" ]; then
    result=$(sed -e "s/$pattern_delete//g" <<< "$result")
  fi

  if [[ $result != "" ]]; then
    if [[ $isTest == "0" ]] && [[ $cfg_log_level == "4" ]]; then
      # log_result=$(sort <<< "$result" | uniq | sed -e 's/^/\\t/g')
      # logDebug "Kategorie: $category (\"$pattern_case\")\n$log_result"
      logDebug "Kategorie: $category (\"$pattern_case\")\n$result"
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
done <<< "$pattern"
# timeb=$(($(date +%s%N)/1000000))
# logInfo "---> $((timeb - timea)) ms"

exit 0
