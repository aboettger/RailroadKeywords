Snippets
==

Doppelte Einträge in den Dateien in "false_positive" finden und löschen

```sh
#!/bin/bash
temp_file=$(mktemp)
find ~/src/RailroadKeywords/false_positive -type f -name "*.pattern" | {
  while read -r file; do
    sort "$file" | uniq > "$temp_file"
    cp "$temp_file" "$file"
  done
}
```

Doppelte Einträge in den Dateien in "true_positive" finden

```sh
#!/bin/bash
temp_file=$(mktemp)
find ~/src/RailroadKeywords/true_positive -type f -name "*.list" | {
  while read -r file; do
    sort "$file" | uniq > "$temp_file"
    cp "$temp_file" "$file"
  done
}
```

Sucht in vorhandenen txt-dateien, die mittels "pdftotext" erzeugt werden, nach einem Suchbegriff und startet "extract_and_write_keywords_into_calibre"

```sh
#!/bin/bash
find ~/Eisenbahn/Eisenbahnliteratur -type f -name '*.txt' ! -name '*human-readable.txt' | {
  while read file; do
    grep -aEl " Rot" "$file" | {
      while read -r pdf; do
        echo "$file"; extract_and_write_keywords_into_calibre "$pdf"
      done
    }
  done
}
```

Sucht in vorhandenen txt-dateien, die mittels "pdftotext" erzeugt werden, nach einem Suchbegriff und zeigt den umgebenen Text an

```sh
#!/bin/bash
find ~/Eisenbahn/Eisenbahnliteratur -type f -name '*.txt' ! -name '*human-readable.txt' | {
  while read file; do
    egrep -anETH -C 5 "EB 65 003 a+b" "$file";
  done
}

```

Findet PDFs ohne txt-Dateien, die mittels "pdftotext" erzeugt werden und startet "extract_and_write_keywords_into_calibre"

```sh
#!/bin/bash
find_with_pdf_without_txt ~/Eisenbahn/Eisenbahnliteratur | {
  while read -r pdf; do
    extract_and_write_keywords_into_calibre "$pdf"
  done
}
```

Textdateien löschen um das System zu zwingen, neue anzulegen

```sh
#!/bin/bash
find ~/Eisenbahn/Eisenbahnliteratur -type f -name '*.txt' | {
  while read file; do
    rm "$file";
  done
}
```

Schreibe "createTxtFile.md5" neu

```sh
#!/bin/bash
find ~/Eisenbahn/Eisenbahnliteratur -type f -name '*.pdf' | {
  while read file; do
    md5_new_CreateTxtFile=$(md5sum "~/src/RailroadKeywords/functions/createTxtFile.sh"  | gawk  -F ' ' '{print $1}');
    echo "$md5_new_CreateTxtFile" > "$(dirname "$file")/createTxtFile.md5";
  done
}
```

Ööhm, ja ;)
```sh
#!/bin/bash
find ~/src/RailroadKeywords/human_readable_pattern/private -type f -name "test-*.pattern" | {
  while read file; do
    keyword_category="$(basename "$file")";
    keyword_category=${keyword_category//test-/};
    keyword_category=${keyword_category//.human_readable.pattern/}; 
    keyword_category=${keyword_category//_/ };
    gawk -v var="$keyword_category" 'NR==1{printf "category=";print var;print;print} NR!=1' "$file"  > "~/tmp/$(basename "$file")";
    mv "~/tmp/$(basename "$file")" "$file";
  done
}
```

Entferne doppelte Leerzeilen

```sh
#!/bin/bash
br="163";
awk '/^$/{ if (! blank++) print; next } { blank=0; print }' ~/src/RailroadKeywords/human_readable_pattern/standard/test-BR_"$br".human_readable.pattern > ~/tmp/test-BR_"$br".human_readable.pattern;
mv ~/tmp/test-BR_"$br".human_readable.pattern ~/src/RailroadKeywords/human_readable_pattern/standard/test-BR_"$br".human_readable.pattern
```

Finde Pattern-Dateien, die sich innerhalb der letzten 12 Stunden geändert haben

```sh
#!/bin/bash
find ~/src/RailroadKeywords/pattern/ -name "*.pattern" -cmin -720 | awk -F/ '{print $7}' | sort
```

Korrigiert in den ASC-Dateien Tabs und " ."

```sh
#!/bin/bash
find 0 -type f -name "*.asc"  | {
  while read file; do
    sed -e 's/\t/ /g' "$file" | sed -e 's/ \././g' > working_copy/$(basename "$file");
  done
}
```

Lösche führende und folgende Leerzeichen, wenn sie mehr als zweimal vorkommen

```sh
#!/bin/bash
find ~/src/RailroadKeywords/tests/standard -type f -name "*.list"  | {
  while read file; do
    sed -e 's/^ */ /g' "$file" | sed -e 's/ *$/ /g' > ~/tmp/list/$(basename "$file");
    mv ~/tmp/list/$(basename "$file") "$file";
  done
}
```

Alle Einträge in "false_positive" nach Schlüsselwörtern durchsuchen lassen

```sh
#!/bin/bash
find "~/src/RailroadKeywords/false_positive" -type f -name "*.pattern" | {
  while read file; do
    ids=$(sed -e '/^#/d' "$file" | grep -E "^[0-9]+=" | gawk  -F '=' '{print $1}' | sort | uniq); echo "$ids" | {
      while read -r line; do
        find ~/Eisenbahn/Eisenbahnliteratur -type d -name "*($line)*" | {
          while read entry; do
            ~/src/RailroadKeywords/extract_and_write_keywords_into_calibre "$entry";
        done };
    done };
done }
```

```sh
#!/bin/bash
calibre_id=$(xpath -q -e "//package/metadata/dc:identifier[@id='calibre_id']/text()" "./metadata.opf");
calibredb list --fields tags --for-machine --search="id:\"=$calibre_id\"" --library-path ~/Eisenbahn/Eisenbahnliteratur  | jshon -e 0 -e "tags" | tr -d "[" | tr -d "]" | tr -d "," | tr -d "\"" | sed -e 's/\\//' | sed -e 's/^ *//g' | sed -e 's/ *$//g' | sed -e '/^$/d'
```


Welche Anfangsbuchstaben für Bezeichnungen in der Art "test-BR_001*" gefiltert werden sollten

```sh
#!/bin/bash
find ~/src/RailroadKeywords/pattern -type f -name "*BR*.pattern" | awk -F "_" '{print $2}' | grep -o "[A-Z]*" | sort | uniq
```

Findet OPF-Dateien, die nach einem bestimmten Datum und Uhrzeit verändert wurden

```sh
#!/bin/bash
touch --date='6 Oct 2014 15:00' /tmp/referenz | find ~/Eisenbahn/Eisenbahnliteratur -type f -name "*.opf" -cnewer /tmp/referenz -exec dirname {} \; | {
  while read file; do
    command;
  done
}
```

tools/test_potentially_false_positive
--

Führt ein "test_potentially_false_positive" auf die Verzeichnisse aus, in denen die Datei "tag_4_test_potentially_false_positive" gefunden wurde
Diese Datei wird erstellt, wenn das Script "extract_and_write_keywords_into_calibre" eine Änderung vorgenommen hat

```sh
#!/bin/bash
find ~/Eisenbahn/Eisenbahnliteratur -type f -name "tag_4_test_potentially_false_positive" -exec dirname {} \; | {
  while read file; do
    echo;
    echo "$file";
    ~/src/RailroadKeywords/tools/test_potentially_false_positive "$file";
    rm "$file"/tag_4_test_potentially_false_positive;
  done
}
```

tools/grep_potentially_false_positive
--

Führt ein "grep_potentially_false_positive" auf die Verzeichnisse aus, in denen die Datei "tag_4_grep_potentially_false_positive" gefunden
Diese Datei wird erstellt, wenn das Script "extract_and_write_keywords_into_calibre" eine Änderung vorgenommen hat

```sh
#!/bin/bash
find ~/Eisenbahn/Eisenbahnliteratur -type f -name "tag_4_grep_potentially_false_positive" -exec dirname {} \; | {
  while read file; do
    echo;
    echo "$file";
    sed -e '/^[[:space:]]*$/d' "~/src/RailroadKeywords/false_positive/potentially_false_positive" | sed -e '/^[[:space:]]*#/d' | {
      while read -r line; do
        echo;
        echo "$line"; ~/src/RailroadKeywords/tools/grep_potentially_false_positive "$file" "*" "$line";
      done
    };
  done
}
```
Für ein Heft alle Schlüsselwörter prüfen

```sh
#!/bin/bash
calibre_id=$(xpath -q -e "//package/metadata/dc:identifier[@id='calibre_id']/text()" "./metadata.opf");
calibredb list --fields tags --for-machine --search="id:\"=$calibre_id\"" --library-path ~/Eisenbahn/Eisenbahnliteratur  | jshon -e 0 -e "tags" | tr -d "[" | tr -d "]" | tr -d "," | tr -d "\"" | sed 's/\\//' | sed 's/^ *//g' | sed 's/ *$//g' | sed '/^$/d' | {
  while read line; do
    result=$(~/src/RailroadKeywords/tools/split_category_and_keyword "$line");
    category=$(grep "category" <<< "$result" | awk -F '\t' '{print $2}');
    keyword=$(grep "keyword" <<< "$result" | awk -F '\t' '{print $2}');
    ~/src/RailroadKeywords/tools/grep_potentially_false_positive . "$category" "$keyword";
  done
};
```
Liste in "false_positive/potentially_false_positive" abarbeiten

```sh
#!/bin/bash
sed -e '/^[[:space:]]*$/d' "~/src/RailroadKeywords/false_positive/potentially_false_positive" | sed -e '/^[[:space:]]*#/d' | {
  while read -r line; do
    echo;
    echo "$line";
    ~/src/RailroadKeywords/tools/grep_potentially_false_positive ~/Eisenbahn/Eisenbahnliteratur "*" "$line";
  done
}
```
Anzahl der möglichen Schlüsselwörter ermitteln
```sh
#!/bin/bash
( find tests/ -name '*.positive.*.list' -print0 | xargs -0 cat ) | wc -l
```

```sh
comm -2 -3  <(sort 118\ 001-999.list) <(sort ../tests/test-BR_118.positive.002.list)
```
