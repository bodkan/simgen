chapters := workshop r-bootcamp tidy-basics tidy-viz slendr

slides_html := $(foreach chapter,$(chapters),rendered/slides_$(chapter).html)
handouts_html := $(foreach chapter,$(chapters),rendered/handout_$(chapter).html)

all: $(slides_html) $(handouts_html)
	git add *.qmd; git commit -m "Update .qmd files"; git push
	quarto publish gh-pages --no-prompt

#	git add rendered/
#	git commit -m "Add rendered HTML slides"

rendered/%.html: slides/%.qmd
	cd slides; \
		quarto render $(notdir $<) --output $(notdir $@); \
		cd ..; \
		mkdir -p rendered; mv slides/$(notdir $@) rendered

handout_%.qmd: slides_%.qmd
	grep -v '### slides' $< | sed 's/^### handout //g' > $@

clean:
	rm -rf *_files *.rmarkdown site_libs *.html *.md slides/*.html slides/*_files

on:
	mv _quarto.yml _quarto.yml_

off:
	mv _quarto.yml_ _quarto.yml
