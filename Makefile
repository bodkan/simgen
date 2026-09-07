chapters := whoami r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),slides_$(chapter).html)
handouts_qmd := $(foreach chapter,$(chapters),handout_$(chapter).qmd)

all: slides handouts book

book: $(slides_html) $(handouts_qmd)
	quarto publish gh-pages --no-prompt
	rm slides_*.html

slides: $(slides_html)
handouts: $(handouts_qmd)

slides_%.html: slides_%.qmd
	quarto render $<

handout_%.qmd: slides_%.qmd
	grep -v '### slides' $< | sed 's/^### handout //g' > $@

clean:
	rm -rf *_files *.rmarkdown
