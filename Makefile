chapters := whoami r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),slides_$(chapter).html)
handouts_html := $(foreach chapter,$(chapters),handout_$(chapter).html)

all: $(slides_html) $(handouts_html)
	quarto publish gh-pages --no-prompt
	git checkout gh-pages
	git checkout main -- slides_*.html handout_*.html
	git add slides_*.html handout_*.html
	git commit -m "Add HTML files"
	git push
	git checkout main
	rm slides_*.html handout_*.html

%.html: %.qmd
	quarto render $<

handout_%.qmd: slides_%.qmd
	grep -v '### slides' $< | sed 's/^### handout //g' > $@

clean:
	rm -rf *_files *.rmarkdown site_libs *.html
