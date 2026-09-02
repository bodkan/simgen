chapters := r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),slides_$(chapter).html)
handouts_qmd := $(foreach chapter,$(chapters),handouts_$(chapter).qmd)

all: slides handouts book

book: $(slides_html) $(handouts_qmd)
	quarto publish gh-pages --no-prompt

slides: $(slides_html)
handouts: $(handouts_qmd)

slides_%.html: slides_%.qmd
	#quarto publish quarto-pub --no-prompt --no-browser $<
	quarto render $<
	git add $@; git commit -m "Update $@"; git push

handouts_%.qmd: slides_%.qmd
	grep -v '### slides' $< | grep -v '^---$$' > $@

clean:
	git rm $(slides_html); git add $(slides_html); git commit -m "Clear slides"; git push
