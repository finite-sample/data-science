# Data Science: Some Basics

Introductory teaching materials by Gaurav Sood on collecting data, working with
databases, statistical learning, clustering, and presenting analyses. The
repository includes six slide decks with editable LaTeX sources, a scraping
assignment, and an R plotting tutorial.

Start with the introduction below and work through the lessons in order. The
PDFs can be read without installing software. The lessons assume basic
probability and linear regression, and some experience writing loops and
functions. For a programming introduction, start with the
[Python workshop](https://github.com/soodoku/python-workshop).

## Lessons

| Lesson | Topics | Materials |
| --- | --- | --- |
| Introduction to Data Science | Data sources and scale, computational constraints, MapReduce, PageRank, and prerequisites | [Slides](ds1/ds1_present_web.pdf) · [Source](ds1/ds1_web.tex) |
| Get Your Own Data | HTML and PDF extraction in Python, regular expressions, edit distance, tokenization, and stemming | [Slides](ds2/ds2_present_web.pdf) · [Source](ds2/ds2_web.tex) · [Assignment](ds2/scraping_assignment_web.txt) |
| Databases and SQL | Data models, XML and JSON, relational algebra, joins, set operations, views, and SQLite | [Slides](ds3/ds3_present_web.pdf) · [Source](ds3/ds3_web.tex) |
| Introduction to Statistical Learning | Nearest neighbors, model flexibility, bias and variance, model evaluation, validation, and false discoveries | [Slides](ds4/ds4_present_web.pdf) · [Source](ds4/ds4_web.tex) |
| Unsupervised Learning | k-means, distance and scaling, choosing the number of clusters, and computational cost | [Slides](ds6/kmeans.pdf) · [Source](ds6/kmeans.tex) |
| Presenting Analyses | ggplot2 mappings, layers, scales, coordinates, facets, uncertainty, and saving plots | [R tutorial](graphs/ggplot2.md) |
| From Paper to Digital | OCR pipelines, recognition errors, error correction, and evaluating extracted text | [Slides](app/PaperToDigital.pdf) · [Source](app/PaperToDigital.tex) |

For more on supervised learning, the companion
[Learning From Data](https://github.com/finite-sample/ds) materials cover
[loss functions and linear regression](https://github.com/finite-sample/ds/tree/master/02_cost),
[bias, variance, and regularization](https://github.com/finite-sample/ds/tree/master/03_bias_variance),
and [model evaluation](https://github.com/finite-sample/ds/tree/master/04_eval).
They also include lessons on causal inference, computer vision, fairness, and
interpretability. The unsupervised deck here concentrates on k-means; PCA is
introduced briefly, and there is no separate correspondence analysis lesson.

## Run the examples

Clone or download the repository. Run commands from its root directory so that
the examples can find the included files.

### Python

Use Python 3.11 or newer. On macOS or Linux:

```sh
git clone https://github.com/finite-sample/data-science.git
cd data-science
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
```

On Windows PowerShell, create the environment with `py -3 -m venv .venv` and
activate it with `.venv\Scripts\Activate.ps1`, then run the same installation
command.

Run the Python examples in the data-collection slides in order, in one Python
session. They use Beautiful Soup, pypdf, and NLTK. The PDF example reads the
included database slides; the HTML and text examples use small inline samples.
These examples need neither API credentials nor NLTK corpus downloads.
Standalone scraping and API scripts are in the
[Python workshop](https://github.com/soodoku/python-workshop).

### R

Install R, then install the plotting packages from an R session:

```r
install.packages(c("ggplot2", "maps"))
```

Run the chunks in [ggplot2 in brief](graphs/ggplot2.md) in order. They use datasets
included with R and ggplot2; the map example uses `maps`.

### Assignment

The [scraping assignment](ds2/scraping_assignment_web.txt) offers two projects:
build a database of NYC legislation, or analyze monthly New York Times coverage
of budget deficits. Use R or Python. Define the collection scope, handle
pagination, check the retrieved records, and submit code, permitted data, plots,
and a short interpretation. The NYT project requires an API key; read it from an
environment variable and keep it out of Git.

## Check the examples

With the Python environment activated, install the development dependencies:

```sh
python -m pip install -r requirements-dev.txt
Rscript -e 'install.packages(c("knitr", "ggplot2", "maps", "cluster"))'
make check
```

`make check` runs Black, isort, and flake8, executes the Python slide examples,
checks JSON, XML, SQL, and regular-expression examples, verifies mathematical
identities in R, and renders the plotting examples. The checks use local data.

Without Make, run the same checks directly:

```sh
python -m black --check tests
python -m isort --profile black --check-only tests
python -m flake8 --max-line-length=88 tests
python -m unittest discover -s tests -v
Rscript tests/check_math.R
```

With Docker and Make installed, `make ci-docker` runs the checks in standard
Python and R containers. It downloads the required images and dependencies.

## Build the slides

The PDFs are included. To rebuild them, install Make and a LaTeX distribution
with pdfLaTeX, Beamer, Helvetica, and cmbright, then run:

```sh
make slides
```

Each deck's source and figures are in its lesson directory. The build writes the
six PDFs linked above. To rebuild one deck, use its PDF path as the Make target,
for example `make ds2/ds2_present_web.pdf`.

## Additional examples

These external projects illustrate applications of the lessons. Some use older
APIs or services; check each project's setup and service availability before
running it.

- OCR: [Tesseract in Python](https://github.com/soodoku/image-to-text),
  [Abbyy FineReader Cloud OCR in R](https://github.com/soodoku/abbyyR), and
  [Captricity in R](https://github.com/soodoku/captr).
- Data collection: [journalists](https://github.com/soodoku/get-journalist-data),
  [weather](https://github.com/soodoku/get-weather-data),
  [cricket](https://github.com/soodoku/get-cricket-data),
  [congressional speeches](https://gist.github.com/soodoku/85d79275c5880f67b4cf),
  [social-media counts](https://github.com/soodoku/likes-followers-views),
  [NYT civil-rights coverage](https://github.com/soodoku/nyt-civil-rights), and
  [social-network data](https://github.com/pablobarbera/social-media-workshop).
- Text analysis: [sentiment analysis](https://gist.github.com/soodoku/22e4cff2eb6a05be3c0d),
  [words and ideology](https://github.com/soodoku/speech-learn), and
  [a text classifier](https://gist.github.com/soodoku/e34dbe0219b0f00a74d5).
- Plotting: NYT civil-rights coverage
  ([R code](https://github.com/soodoku/nyt-civil-rights/blob/master/plot.R),
  [plot](https://github.com/soodoku/nyt-civil-rights/blob/master/nyt_aa.pdf)) and
  military experience of UK prime ministers
  ([R code](https://github.com/soodoku/military-experience/blob/master/mil_plots.R),
  [plot](https://github.com/soodoku/military-experience/blob/master/ukmil.pdf)).
- [Suggestions for writing](http://gbytes.gsood.com/on-writing/).

## Suggested books

- [The Elements of Statistical Learning](https://hastie.su.domains/ElemStatLearn/),
  by Trevor Hastie, Robert Tibshirani, and Jerome Friedman.
- [Python Programming: An Introduction to Computer Science](https://mcsp.wartburg.edu/zelle/python/),
  by John Zelle.
- [ggplot2: Elegant Graphics for Data Analysis](https://ggplot2-book.org/),
  by Hadley Wickham, Danielle Navarro, and Thomas Lin Pedersen.

## License

[Creative Commons Attribution-ShareAlike 4.0 International](License.md).
