RailroadKeywords
================

Requirements
------------
* **Calibre** (http://calibre-ebook.com/)
* Aktuellste Version von **pdfminer** (https://github.com/euske/pdfminer)

Beschreibung
------------

Dieses Projekt soll aus vorhandenen PDFs alle (mir) bekannten Baureihen deutscher Lokomotiven und Triebwagen extrahieren. Es besteht aus drei Einzelprogrammen, die auch unabhängig voneinander einsetzbar sind.

**create_railroad_keywords_from_pdf**

Mit diesem Programm werden Schlüsselwörter aus PDFs extrahiert. Dazu wird mit pdftotext eine Textdatei im gleichen Verzeichnis angelegt, die noch etwas optimiert wird, um sie besser durchsuchen zu können. Außerdem wird für das PDF die md5-Prüfsumme berechnet und ebenfalls im Verzeichnis abgelegt. Sollte die Textdatei und/oder die Prüfsmmendatei fehlen, so werden sie erneut angelegt. Sollte sich die Prüfsumme des PDF ändern, so wird die Textdatei neu angelegt.
Welche Schlüsselwörter gefunden werden sollen ist durch reguläre Ausdrücke in den Dateien im Verzeichnis "pattern" dieses Projekts definiert. Damit diese möglichst genau arbeiten können Tests durchgeführt werden. Die Testdateien befinden sich im Verzeichnis "tests".
Im Verzeichnis "false_positive" werden Schlüsselwörter abgelegt, die für ein PDF nicht zutreffend sind. Die Einträge in den einzelnen Dateien setzen sich aus der Calibre-ID und einem regulären Ausdruck zusammen. Die im Projekt vorhandenen Dateien können nur als Vorlage dienen, da die verwendeten Calibre-IDs meine Datenbank wiederspiegeln.

* Pattern-Dateien erzeugen
Im Verzeichnis "RailroadKeywords/human_readable_pattern" liegen Pattern-Dateien, die lesbar und damit wartbar sind. Das Script "RailroadKeywords/tools/compress_pattern" komprimiert diese Dateien und legt diese im Verzeichnis "RailroadKeywords/pattern" ab. Natürlich können in diesem Verzeichnis auch die "human_readable"-Dateien liegen, dann wird das Laufzeitverhalten aber schlechter.

* Alle Tests durchführen
```create_railroad_keywords_from_pdf test [Projektverzeichnis]/RailroadKeywords/pattern/```

* Einzeltest durchführen
```create_railroad_keywords_from_pdf test [Projektverzeichnis]/RailroadKeywords/pattern/[test-....txt]```

* Schlüsselwörter erzeugen
```create_railroad_keywords_from_pdf run [Projektverzeichnis]/RailroadKeywords/pattern/ [PDF]```

**extract_and_write_keywords_into_calibre**

Dieses Programm verwendet "create_railroad_keywords_from_pdf" um aus den PDFs in einer Calibre-Bibliothek Schlüsselwörter zu extrahieren, um diese in die Metadaten des Eintrags in der Calibre-Bibliothek zu schreiben

```extract_and_write_keywords_into_calibre [CalibreBibliotheksVerzeichnis]```

**update_pdf_metadata_by_calibre**

Dieses Programm kann die Angaben in den Metadaten für ein PDF in der Calibre-Bibliothek in das PDF übertragen. Dabei werden die md5-Prüfsummen, die "create_railroad_keywords_from_pdf" verwendet, neu abgelegt, da sich das PDF an sich nicht geändert hat uns somit keine neue Erzeugung der Textdatei durch "create_railroad_keywords_from_pdf" nötig ist.

```update_pdf_metadata_by_calibre [CalibreBibliotheksVerzeichnis]```

Related Projects
----------------

 * <a href="https://github.com/euske/pdfminer">pdfminer</a>
