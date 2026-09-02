chapters := r-bootcamp tidy-basics tidy-viz slendr

rendered_dir := rendered

slides_html := $(foreach chapter,$(chapters),$(rendered_dir)/slides_$(chapter).html)
handouts_qmd := $(foreach chapter,$(chapters),handouts_$(chapter).qmd)

all: slides handouts book

book: $(handouts_qmd)
	quarto publish gh-pages --no-prompt

slides: $(slides_html)
handouts: $(handouts_qmd)

$(rendered_dir)/slides_%.html: slides_%.qmd
	#quarto publish quarto-pub --no-prompt --no-browser $<
	quarto render $<
	mkdir -p $(rendered_dir)
	mv $(notdir $@) $(rendered_dir)
	git checkout gh-pages; git add $@; git commit -m "Update $@"; git push; git checkout main

handouts_%.qmd: slides_%.qmd
	grep -v '### slides' $< | grep -v '^---$$' > $@

clean:
	rm -rf  $(rendered_dir)
