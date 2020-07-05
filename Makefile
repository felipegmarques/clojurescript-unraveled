all: build

setup:
	mkdir -p dist/

copy: setup
	cp -r ./images dist/
	cp -r ./assets dist/

html: setup
	asciidoctor -b xhtml -a docinfo -a stylesheet! src/index.adoc -o dist/index.html

htmlcljsinfo: setup
	asciidoctor -b xhtml -a docinfo -a stylesheet=../assets/stylesheet.cljsinfo.css  src/index.adoc -o dist/index.html

git:
	git submodule init
	git submodule update

docbook: setup
	asciidoctor -b docbook -a numbered -d book -a data-uri!  src/index.adoc -o dist/clojure-unraveled.xml

pdf: docbook
	./asciidoctor-fopub/fopub -t docbook-xsl dist/clojure-unraveled.xml
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=dist/_clojure-unraveled.pdf cover/cover.pdf dist/clojure-unraveled.pdf
	mv dist/_clojure-unraveled.pdf dist/clojure-unraveled.pdf

rawpdf:
	./asciidoctor-fopub/fopub -t docbook-xsl dist/clojure-unraveled.xml

epub: docbook copy
	./docbook-xsl/bin/dbtoepub -s xsl-styleshets/epub/docbook.xsl  dist/clojure-unraveled.xml -o dist/_clojure-unraveled.epub
	ebook-convert dist/_clojure-unraveled.epub dist/clojure-unraveled.epub --chapter="/" --no-chapters-in-toc --cover=cover/cover.png --authors="Andrey Antukh & Alejandro Gomez"

mobi: epub
	ebook-convert dist/_clojure-unraveled.epub dist/clojure-unraveled.mobi --output-profile=kindle --chapter="/" --no-chapters-in-toc --cover=cover/cover.png --mobi-ignore-margins --margin-left=2 --margin-right=2

github: html
	ghp-import -m "Generate book" -b clojure dist/
	git push origin clojure

clean:
	rm -r dist/

build: copy html

buildcljsinfo: copy htmlcljsinfo

watch: build
	sh ./watch.sh

watchcljsinfo: buildcljsinfo
	sh ./watch.sh htmlcljsinfo

release: clean pdf epub mobi html github
