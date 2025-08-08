chapters := slendr

rendered_dir := rendered

$(shell mkdir -p $(rendered_dir))

slides_qmd := $(foreach chapter,$(chapters),slides_$(chapter).qmd)
slides_html := $(subst .qmd,.html,$(slides_qmd))

handouts_qmd := $(subst slides,handouts,$(slides_qmd))
handouts_html := $(subst slides,handouts,$(slides_html))

debug:
	@echo $(slides_qmd)
	@echo $(handouts_qmd)
	@echo "---"
	@echo $(slides_html)
	@echo $(handouts_html)

all: book slides handouts

book:
	quarto publish gh-pages

slides: $(addprefix $(rendered_dir)/,$(slides_html))

handouts: $(addprefix $(rendered_dir)/,$(handouts_html))

$(rendered_dir)/slides_%.html: slides_%.qmd
	sed -i '/### handouts/ s/^/#/' $<
	sed -i '/### remove for slides/d' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	mv $(notdir $@) $(rendered_dir); rm $<

$(rendered_dir)/handouts_%.html: handouts_%.qmd
	sed -i '/### slides/ s/^/#/' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	mv $(notdir $@) $(rendered_dir); rm $<

slides_%.qmd: %.qmd
	cat slides_header.txt $< slides_footer.txt > $@

handouts_%.qmd:
	cat slides_header.txt $< slides_footer.txt > $@

clean:
	rm -rf $(slides_qmd) $(handouts_qmd) $(slides_html) $(handouts_html) $(rendered_dir)
