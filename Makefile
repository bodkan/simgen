chapters := whoami r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),rendered/slides_$(chapter).html)
handouts_html := $(foreach chapter,$(chapters),rendered/handout_$(chapter).html)

all: $(slides_html) $(handouts_html)
	quarto publish gh-pages --no-prompt
	git checkout gh-pages
	git checkout main -- rendered/
	git add rendered/
	git commit -m "Add HTML files"
	git push
	git checkout main
	rm -r rendered/

rendered/%.html: %.qmd
	mkdir -p rendered
	quarto render $< --output $@

handout_%.qmd: slides_%.qmd
	grep -v '### slides' $< | sed 's/^### handout //g' > $@

clean:
	rm -rf *_files *.rmarkdown site_libs *.html
