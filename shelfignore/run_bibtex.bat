REM BibRun: Batch-Datei für LaTeX
REM Führt den Run zum Erzeugen des Literaturverzeichnises
REM mit BibTex durch
REM Dieser Text als Textdatei mit der Endung ".bat" in das
REM gleiche Verzeichnis ablegen, wie die LaTeX-Datei,
REM die Variablen-Definitionen SET LATEXPORT und
REM SET MAINFILE anpassen und dann mit Doppelklick starten
REM
REM Letztes Update 16.05.2013

ECHO OFF
ECHO "BibRun v1.0"

REM Pfad zu den Programmen von Latex-Portable - absolute Pfad ist notwendig
REM da sonst die Files nicht gefunden werden.
SET LATEXPORT="U:\Eigene Dateien\LaTeX_portable\MikTex-portable\miktex\bin\"

REM Dateiname (ohne ".tex") der LaTeX-Datei
SET MAINFILE="main"

%LATEXPORT%"latex.exe" -interaction=nonstopmode %MAINFILE%.tex
%LATEXPORT%"bibtex.exe" %MAINFILE%.aux
%LATEXPORT%"latex.exe" -interaction=nonstopmode %MAINFILE%.tex
%LATEXPORT%"latex.exe" -interaction=nonstopmode %MAINFILE%.tex

REM Erfolgsmeldung ...
ECHO BibRun terminated!
ECHO Use PDFLatex for PDF-File!

PAUSE