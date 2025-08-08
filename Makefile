chapters := slendr

rendered_dir := rendered

handouts_qmd := $(subst slides,handouts,$(slides_qmd))

debug:
	@echo $(slides_qmd)
	@echo $(handouts_qmd)
	@echo "---"
	@echo $(slides_html)
	@echo $(handouts_html)

all: book slides handouts

book: $(handouts_qmd)
	quarto publish gh-pages --no-prompt

slides: $(addprefix $(rendered_dir)/,$(slides_html))

$(rendered_dir)/slides_%.html: slides_%.qmd
	mkdir -p $(rendered_dir)
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	mv $(notdir $@) $(rendered_dir); rm $<

handouts_%.qmd: %.qmd
	grep -v '### slides' $< > $@

clean:
	rm -rf  $(rendered_dir)
