chapters := slendr

rendered_dir := rendered

slides_html := $(foreach chapter,$(chapters),$(rendered_dir)/slides_$(chapter).html)
handouts_qmd := $(foreach chapter,$(chapters),handouts_$(chapter).qmd)

debug:
	@echo $(slides_html)
	@echo $(handouts_qmd)

all: book slides

book: $(handouts_qmd)
	quarto publish gh-pages --no-prompt

slides: $(slides_html)
handouts: $(handouts_qmd)

$(rendered_dir)/slides_%.html: slides_%.qmd
	mkdir -p $(rendered_dir)
	quarto publish quarto-pub --no-prompt --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	mv $(notdir $@) $(rendered_dir)

handouts_%.qmd: slides_%.qmd
	grep -v '### slides' $< | grep -v '^---$$' > $@

clean:
	rm -rf  $(rendered_dir)
