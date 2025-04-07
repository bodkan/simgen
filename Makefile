all: book

book:
	quarto publish gh-pages

slides: slides.qmd
	sed -i '/### handouts/ s/^/#/' slides.qmd
	quarto render slides.qmd -o slides.html
	quarto publish quarto-pub --id 89c6a0e8-85a2-4c7c-8f00-76a654bb3394 slides.qmd
	sed -i '/### handouts/ s/^#//' slides.qmd
	git add slides.html; git commit -m "Update slides.html"; git push
	rm slides.qmd

handouts: handouts.qmd
	sed -i '/### slides/ s/^/#/' handouts.qmd
	quarto render handouts.qmd -o handouts.html
	quarto publish quarto-pub --id 0289a039-7c5d-44a8-8487-f2fcb3ff4294 handouts.qmd
	sed -i '/### slides/ s/^#//' slides.qmd
	git add handouts.html; git commit -m "Update handouts.html"; git push
	rm handouts.qmd

slides.qmd:
	cat slides_header.txt slendr-why.qmd slendr-crash-course.qmd > slides.qmd

handouts.qmd:
	cat slides_header.txt slendr-why.qmd slendr-crash-course.qmd > handouts.qmd