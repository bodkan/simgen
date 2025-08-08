chapters := slendr

rendered_dir := rendered

slides_qmd := $(foreach chapter,$(chapters),$(rendered_dir)/slides_$(chapter).html)
handouts_qmd := $(subst slides,handouts,$(slides_qmd))

slides_html := $(subst .html,.qmd,$(slides_qmd))
handouts_html := $(subst .html,.qmd,$(handouts_qmd))

all: book slides_html handouts_html

book:
	quarto publish gh-pages

slides_html: $(slides_html)

handouts_html: $(handouts_html)

$(rendered_dir)/slides_%.html: $(rendered_dir)/slides_%.qmd
	sed -i '/### handouts/ s/^/#/' $<
	sed -i '/### remove for slides/d' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	rm $<

$(rendered_dir)/handouts_%.html: $(rendered_dir)/handouts_%.qmd
	sed -i '/### slides/ s/^/#/' $<
	quarto publish quarto-pub --no-browser $<
	git add $@; git commit -m "Update $@"; git push
	rm $<

$(rendered_dir)/slides_%.qmd: %.qmd
	mkdir -p $(rendered_dir)
	cat slides_header.txt $< slides_footer.txt > $@

$(rendered_dir)/handouts_slendr.qmd:
	mkdir -p $(rendered_dir)
	cat slides_header.txt $< slides_footer.txt > $@

clean:
	rm -r $(rendered_dir)