all: book slides handouts

book:
	quarto publish gh-pages

#slides: slides.qmd
#	sed -i '/### handouts/ s/^/#/' slides.qmd
#	sed -i '/### remove for slides/d' slides.qmd
#	quarto render slides.qmd -o slides.html
#	quarto publish quarto-pub --id 9ae2ff0a-239b-476f-aa87-aada1286d496 slides.qmd
#	git add slides.html; git commit -m "Update slides.html"; git push
#	rm slides.qmd
#
#handouts: handouts.qmd
#	sed -i '/### slides/ s/^/#/' handouts.qmd
#	quarto render handouts.qmd -o handouts.html
#	quarto publish quarto-pub --id 42a06e3d-d46b-4833-8cb9-9c03e0c304f7 handouts.qmd
#	git add handouts.html; git commit -m "Update handouts.html"; git push
#	rm handouts.qmd
#
#slides.qmd:
#	cat slides_header.txt slendr-why.qmd slendr-crash-course.qmd slides_footer.txt > slides.qmd
#
#handouts.qmd:
#	cat slides_header.txt slendr-why.qmd slendr-crash-course.qmd slides_footer.txt > handouts.qmd
