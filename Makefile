all: slides handouts exercises

#slides:
#	sed -i '/### handouts/ s/^/#/' slides.qmd
#	quarto render slides.qmd -o slides.html
#	quarto publish quarto-pub --id <QUARTOPUB ID> slides.qmd
#	sed -i '/### handouts/ s/^#//' slides.qmd
#	git add slides.qmd; git commit -m "Update slides.qmd"; git push
#	git add slides.html; git commit -m "Update slides.html"; git push
#
#handouts:
#	sed -i '/### slides/ s/^/#/' slides.qmd
#	quarto render slides.qmd -o handouts.html
#	quarto publish quarto-pub --id <QUARTOPUB ID> slides.qmd
#	sed -i '/### slides/ s/^#//' slides.qmd
#	git checkout slides.html
#	git add slides.qmd; git commit -m "Update slides.qmd"; git push
#	git add handouts.html; git commit -m "Update handouts.html"; git push

book:
	quarto render book.qmd -o book.html
	quarto publish quarto-pub --id 8e5cfd98-1d99-48e8-8045-070ea7562ae4 book.qmd
	git add book*; git commit -m "Update book"; git push
