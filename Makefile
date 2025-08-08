chapters := slendr

slides_qmd := $(foreach chapter,$(chapters),slides_$(chapter).html)
handouts_qmd := $(foreach chapter,$(chapters),handouts_$(chapter).html)

slides_html := $(subst .html,.qmd,$(slides_qmd))
handouts_html := $(subst .html,.qmd,$(handouts_qmd))

all: book slides handouts

book:
	quarto publish gh-pages

slides: $(slides_html)

handouts: $(handouts_html)

slides_%.html: slides_%.qmd
	sed -i '/### handouts/ s/^/#/' $<
	sed -i '/### remove for slides/d' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	rm $<

handouts_%.html: handouts_%.qmd
	sed -i '/### slides/ s/^/#/' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	rm $<

slides_%.qmd: %.qmd
	cat slides_files/slides_header.txt $< slides_files/slides_footer.txt > $@

handouts_slendr.qmd:
	cat slides_files/slides_header.txt $< slides_files/slides_footer.txt > $@

clean_qmd:
	rm -f $(slides_qmd) $(handouts_qmd)

clean_html:
	rm -f $(slides_html) $(handouts_html) $(slides_qmd) $(handouts_qmd)