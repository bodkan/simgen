chapters := whoami r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),slides_$(chapter).html)
handouts_html := $(foreach chapter,$(chapters),handout_$(chapter).html)

all: $(slides_html) $(handouts_html)
	quarto publish gh-pages --no-prompt
	git checkout gh-pages
	rm -r rendered; mv tmp/ rendered/
	git add rendered/
	git commit -m "Add HTML files"
	git push
	git checkout .DS_Store
	git checkout main

slides: $(slides_html)
handouts: $(handouts_html)

%.html: %.qmd
	quarto render $< --output $(notdir $@)
	mkdir -p tmp; mv $@ tmp

handout_%.qmd: slides_%.qmd
	grep -v '### slides' $< | sed 's/^### handout //g' > $@

clean:
	rm -rf *_files *.rmarkdown site_libs *.html tmp/ rendered/
