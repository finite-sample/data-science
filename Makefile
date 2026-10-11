PYTHON ?= python3
RSCRIPT ?= Rscript
PDF := ds1/ds1_present_web.pdf ds2/ds2_present_web.pdf ds3/ds3_present_web.pdf ds4/ds4_present_web.pdf ds6/kmeans.pdf app/PaperToDigital.pdf

.PHONY: check lint test slides ci-docker

check: lint test

lint:
	$(PYTHON) -m black --check tests
	$(PYTHON) -m isort --profile black --check-only tests
	$(PYTHON) -m flake8 --max-line-length=88 tests

test:
	$(PYTHON) -m unittest discover -s tests -v
	$(RSCRIPT) tests/check_math.R

slides: $(PDF)

ds1/ds1_present_web.pdf: ds1/ds1_web.tex
ds2/ds2_present_web.pdf: ds2/ds2_web.tex
ds3/ds3_present_web.pdf: ds3/ds3_web.tex
ds4/ds4_present_web.pdf: ds4/ds4_web.tex
ds6/kmeans.pdf: ds6/kmeans.tex
app/PaperToDigital.pdf: app/PaperToDigital.tex

$(PDF): $(wildcard */*.png */*.jpg */img/*)
	cd $(@D) && pdflatex -halt-on-error -interaction=nonstopmode -jobname=$(@F:.pdf=) $(notdir $(filter %.tex,$^))
	cd $(@D) && pdflatex -halt-on-error -interaction=nonstopmode -jobname=$(@F:.pdf=) $(notdir $(filter %.tex,$^))

ci-docker:
	docker run --rm -v "$(CURDIR):/work:ro" -w /work python:3.14-slim \
		sh -c 'pip install -r requirements-dev.txt && python -m black --check tests && python -m isort --profile black --check-only tests && python -m flake8 --max-line-length=88 tests && python -m unittest discover -s tests -v'
	docker run --rm -v "$(CURDIR):/work:ro" -w /work r-base:latest \
		Rscript -e 'install.packages(c("knitr", "ggplot2", "maps"), repos="https://cloud.r-project.org"); source("tests/check_math.R")'
