chapters := slendr

slides_qmd := $(foreach chapter,$(chapters),rendered/slides_$(chapter).html)
handouts_qmd := $(foreach chapter,$(chapters),rendered/handouts_$(chapter).html)

slides_html := $(subst .html,.qmd,$(slides_qmd))
handouts_html := $(subst .html,.qmd,$(handouts_qmd))

all: book slides_html handouts_html

book:
	quarto publish gh-pages

slides_html: $(slides_html)

handouts_html: $(handouts_html)

rendered/slides_%.html: slides_%.qmd
	sed -i '/### handouts/ s/^/#/' $<
	sed -i '/### remove for slides/d' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	rm $<

rendered/handouts_%.html: handouts_%.qmd
	sed -i '/### slides/ s/^/#/' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	rm $<

rendered/slides_%.qmd: %.qmd
	cat slides_files/slides_header.txt $< slides_files/slides_footer.txt > $@

rendered/handouts_slendr.qmd:
	cat slides_files/slides_header.txt $< slides_files/slides_footer.txt > $@

clean_qmd:
	rm -f $(slides_qmd) $(handouts_qmd)

clean_html:
	rm -f $(slides_html) $(handouts_html) $(slides_qmd) $(handouts_qmd)