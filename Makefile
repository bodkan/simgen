chapters := r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),slides_$(chapter).html)
handouts_qmd := $(foreach chapter,$(chapters),handouts_$(chapter).qmd)

all: slides handouts book

book: $(handouts_qmd)
	quarto publish gh-pages --no-prompt

slides: $(slides_html)
handouts: $(handouts_qmd)

slides_%.html: slides_%.qmd
	#quarto publish quarto-pub --no-prompt --no-browser $<
	quarto render $<
	git checkout gh-pages; git add $@; git commit -m "Update $@"; git push; git checkout main

handouts_%.qmd: slides_%.qmd
	grep -v '### slides' $< | grep -v '^---$$' > $@

clean:
	git checkout gh-pages; git rm -r $(slides_html); git add $(slides_html); git commit -m "Clear slides"; git push; git checkout main
