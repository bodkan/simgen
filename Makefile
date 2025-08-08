all: book slides handouts

book:
	quarto publish gh-pages

slides: slides_slendr.qmd
	sed -i '/### handouts/ s/^/#/' slides_slendr.qmd
	sed -i '/### remove for slides/d' slides_slendr.qmd
	quarto publish quarto-pub slides_slendr.qmd
	git add slides_slendr.html; git commit -m "Update slides_slendr.html"; git push
	rm slides_slendr.qmd

handouts: handouts_slendr.qmd
	sed -i '/### slides/ s/^/#/' handouts_slendr.qmd
	quarto render handouts_slendr.qmd -o handouts_slendr.html
	quarto publish quarto-pub --id 42a06e3d-d46b-4833-8cb9-9c03e0c304f7 handouts_slendr.qmd
	git add handouts_slendr.html; git commit -m "Update handouts_slendr.html"; git push
	rm handouts_slendr.qmd

slides_slendr.qmd:
	cat slides_files/slides_header.txt slendr-why.qmd slendr-crash-course.qmd slides_files/slides_footer.txt > slides_slendr.qmd

handouts_slendr.qmd:
	cat slides_files/slides_header.txt slendr-why.qmd slendr-crash-course.qmd slides_files/slides_footer.txt > handouts_slendr.qmd
