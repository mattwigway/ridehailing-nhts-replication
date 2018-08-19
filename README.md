## Replication package for Conway, Salon and King. "Trends in Taxi Use and the Advent of Ridehailing, 1995--2017: Evidence from the US National Household Travel Survey"

This replication package contains all the code needed to replicate the results in the aforementioned paper. Most of the code is in Python, with some model estimation code written in Stata. Stata 15.1 was used, and the `outreg2` package is needed (to install, run `ssc install outreg2`). Python dependency management is handled with [Anaconda](https://www.anaconda.com/download/). To get the same environment I had when producing the original figures and results in the paper, run

    conda env create
    source activate ridehailing-nhts

(These commands work on Mac OS and Linux; slightly different commands may be needed for Windows users.)

You will also need to obtain the NHTS data for 1995, 2001, 2009, and 2017; this is available from [the NHTS website](https://nhts.ornl.gov). Download the CSV files (both the main and the replicate weight files, for years that have them separately). The 1995 NPTS is available from a [separate legacy site](https://nhts.ornl.gov/download.shtml). Unzip the files into the following directory structure in the `data` folder (note that the schema files for 1995 were made by hand and are included with this replication package):

```
data
├── 1995
│   ├── Hhold95.lst
│   ├── Hhold95.txt
│   ├── PERS95_2.TXT
│   ├── PERS95_2_schema.csv
│   ├── Pertrp95.lst
│   ├── Pertrp95.txt
│   ├── Pertrp95_schema.csv
│   ├── Segtrp95.lst
│   ├── Segtrp95.txt
│   ├── Segtrp95_schema.csv
│   ├── Vehicl95.lst
│   ├── Vehicl95.txt
│   ├── dtrp95_2.lst
│   ├── dtrp95_2.txt
│   ├── dtrp95_2_schema.csv
│   └── pers95_2.lst
├── 2001
│   ├── DAYPUB.csv
│   ├── HHPUB.csv
│   ├── LDTPUB.csv
│   ├── PERPUB.csv
│   ├── VEHPUB.csv
│   ├── hh50wt.csv
│   ├── ldt50wt.csv
│   └── pr50wt.csv
├── 2009
│   ├── Ascii
│   │   ├── DAYV2PUB.CSV
│   │   ├── HHV2PUB.CSV
│   │   ├── PERV2PUB.CSV
│   │   ├── VEHV2PUB.CSV
│   ├── Citation.docx
│   ├── hh50wt.csv
│   └── per50wt.csv
├── 2017
│   ├── Citation.docx
│   ├── hhpub.csv
│   ├── hhwgt.csv
│   ├── perpub.csv
│   ├── perwgt.csv
│   ├── trippub.csv
│   └── vehpub.csv
```

You can then start up the [Jupyter Notebook](http://jupyter.org/) by typing `jupyter notebook`.

There are several notebooks, which are described below. If you have any questions, please don't hesitate to contact me at [mwconway@asu.edu](mailto:mwconway@asu.edu).

### Notebooks

Demographics and Trends are the two main notebooks, with other notebooks serving ancillary functions.

- [Demographics.ipynb](notebooks/Demographics.ipynb)
  This notebook contains demographic analysis of ridehailing users in 2017.

- [Trends.ipynb](notebooks/Trends.ipynb)
  This notebook contains analysis of trends since 2009.

- [Tours.ipynb](notebooks/Tours.ipynb)
  This notebook analyzes the multimodality of tours, including autos and for-hire vehicles.

- [Weighted Unweighted Comparison.ipynb](notebooks/Weighted Unweighted Comparison.ipynb)
  This generates a visual comparison between the weighted and unweighted models.

### Stata files

- [logistic.do](stata/logistic.do)
  This script fits the logit model we present in the paper, and computes VIFs. The Demographics notebook must be run prior to running this Stata file, as that notebook formats the data for Stata's use.
- [weighted_unweighted.do](stata/weighted_unweighted.do)
  This script fits both the logit
