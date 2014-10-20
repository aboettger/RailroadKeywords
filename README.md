RailroadKeywords
================
**Vielen Dank an Ingo Hütter und sein Projekt <a href="http://www.beitraege.lokomotive.de/">Beiträge zur Lokomotiv- und Eisenbahngeschichte</a>**

Anforderungen
------------
* **Calibre** (http://calibre-ebook.com/)
* Aktuellste Version von **pdfminer** (https://github.com/euske/pdfminer)

___
Beschreibung
--

Dieses Projekt soll aus vorhandenen PDFs alle (mir) bekannten Baureihen deutscher Lokomotiven und Triebwagen extrahieren.
Es besteht im wesentlichen aus zwei Programmen, wobei im Normalfall nur **extract_and_write_keywords_into_calibre** zur direkten Ausführung kommt:

**create_railroad_keywords_from_pdf**
* Mittels diesem Programm werden die Schlüsselwörter ausgelesen bzw. Tests durchgeführt.
* Dieses Programm wird von **extract_and_write_keywords_into_calibre** direkt aufgerufen.

**extract_and_write_keywords_into_calibre**
* Das Hauptprogramm des Projekts.
* Ausgaben werden von ```create_railroad_keywords_from_pdf``` entgegen genommen und weiter verarbeitet.

___

Konfiguration
--
Eine Beispielkonfiguration ist im Hauptverzeichnis des Projekts zu finden und hört auf den Namen ```main.cfg.template```. Diese Konfiguration wird durch den folgenden Befehl zu einer echten Konfigurationsdatei:
```
cp main.cfg.template main.cfg
```
Weitere Erläuterungen befinden sich in der genannten Konfigurationsdatei.

___

Der erste Start
--

Für den ersten Start genügt es
* die Konfiguration, wenn nötig, anzupassen
* die Tests laufen zu lassen
* das Hauptprogramm zu starten

```sh
tools/run_tests
extract_and_write_keywords_into_calibre "CalibreBibliotheksVerzeichnis_Oder_CalibreBibliotheksUnterverzeichnis"

```
Wenn das Projekt also im Verzeichnis "~/src" liegt und die PDFs in der Calibre-Bibliothek "~/MeineEisenbahnliteratur" dann sieht das so aus:
```sh
~/src/RailroadKeywords/tools/run_tests
~/src/RailroadKeywords/extract_and_write_keywords_into_calibre "~/MeineEisenbahnliteratur"

```
___
Weitere Erläuterungen
--
**tools/run_tests**

Mit diesem Tool werden die Pattern-Dateien neu angelegt getestet, damit sie alles finden, was sie finden sollen.

**create_railroad_keywords_from_pdf**

Mit diesem Programm werden Schlüsselwörter aus PDFs extrahiert. Dazu wird mit pdftotext eine Textdatei im gleichen Verzeichnis angelegt, die noch etwas optimiert wird, um sie besser durchsuchen zu können. Außerdem wird für das PDF die md5-Prüfsumme berechnet und ebenfalls im Verzeichnis abgelegt. Sollte die Textdatei und/oder die Prüfsmmendatei fehlen, so werden sie erneut angelegt. Sollte sich die Prüfsumme des PDF ändern, so wird die Textdatei neu angelegt.
Welche Schlüsselwörter gefunden werden sollen ist durch reguläre Ausdrücke in den Dateien im Verzeichnis "pattern" dieses Projekts definiert. Damit diese möglichst genau arbeiten können Tests durchgeführt werden. Die Testdateien befinden sich im Verzeichnis "tests".
Im Verzeichnis "false_positive" werden Schlüsselwörter abgelegt, die für ein PDF nicht zutreffend sind. Die Einträge in den einzelnen Dateien setzen sich aus der Calibre-ID und einem regulären Ausdruck zusammen. Die im Projekt vorhandenen Dateien können nur als Vorlage dienen, da die verwendeten Calibre-IDs meine Datenbank wiederspiegeln.

**compress_pattern**

Pattern-Dateien erzeugen:

Im Verzeichnis ```RailroadKeywords/human_readable_pattern/standard``` bzw. ```RailroadKeywords/human_readable_pattern/private``` liegen Pattern-Dateien, die lesbar und damit wartbar sind. Das Script ```RailroadKeywords/tools/compress_pattern``` komprimiert diese Dateien und legt diese im Verzeichnis ```RailroadKeywords/pattern``` ab.
  
  ```sh
  compress_pattern
  ```

**Alle Tests durchführen**

  Mit diesem Direktaufruf werden die Pattern-Dateien getestet. Die zu testenden Werte sind im Verzeichnis ```tests/standard``` bzw. ```tests/private```abgelegt
  ```sh
  create_railroad_keywords_from_pdf test [Projektverzeichnis]/RailroadKeywords/pattern/
  ```

**Einzeltest durchführen**
```sh
create_railroad_keywords_from_pdf test [Projektverzeichnis]/RailroadKeywords/pattern/[test-....txt]
```

**Schlüsselwörter erzeugen**
```sh
create_railroad_keywords_from_pdf run [Projektverzeichnis]/RailroadKeywords/pattern/ [PDF]
```

**Schlüsselwörter in Calibre-Datenbank schreiben**

Dieses Programm verwendet **create_railroad_keywords_from_pdf** um aus den PDFs in einer Calibre-Bibliothek Schlüsselwörter zu extrahieren, um diese in die Metadaten des Eintrags in der Calibre-Bibliothek zu schreiben

```sh
extract_and_write_keywords_into_calibre [CalibreBibliotheksVerzeichnis]
```

**Schlüsselwörter in PDFs übertragen**

Dieses Programm kann die Angaben in den Metadaten für ein PDF in der Calibre-Bibliothek in das PDF übertragen. Dabei werden die md5-Prüfsummen, die "create_railroad_keywords_from_pdf" verwendet, neu abgelegt, da sich das PDF an sich nicht geändert hat uns somit keine neue Erzeugung der Textdatei durch "create_railroad_keywords_from_pdf" nötig ist.

```sh
update_pdf_metadata_by_calibre [CalibreBibliotheksVerzeichnis]
```
___
Related Projects
----------------

 * <a href="http://www.beitraege.lokomotive.de/">Beiträge zur Lokomotiv- und Eisenbahngeschichte</a> 
 * <a href="https://github.com/euske/pdfminer">pdfminer</a>
