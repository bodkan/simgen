chapters := workshop r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),rendered/slides_$(chapter).html)
handouts_html := $(foreach chapter,$(chapters),rendered/handout_$(chapter).html)

all: $(slides_html) $(handouts_html)
	rm -r slides/*.html slides/*_files
	git add *.qmd; git commit -m "Update .qmd files"; git push
	quarto publish gh-pages --no-prompt
	git checkout gh-pages
	git add rendered/
	git commit -m "Add rendered HTML slides"
	git push
	git checkout main
	rm -f slides/handout_*.qmd

rendered/%.html: slides/%.qmd
	cd slides; \
		quarto render $(notdir $<) --output $(notdir $@); \
		cd ..; \
		mkdir -p rendered; mv slides/$(notdir $@) rendered

handout_%.qmd: slides_%.qmd
	grep -v '### slides' $< | sed 's/^### handout //g' > $@

clean:
	rm -rf *_files *.rmarkdown site_libs *.html rendered/ *.md slides/*.html slides/*_files
