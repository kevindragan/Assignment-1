# REM16 and FT1 expression analysis

This R analysis extracts REM16 (`LOC115699937`) and FT1 (`LOC115696989`) expression from the cannabis RNA-seq dataset and creates a box plot for each gene and a combined figure grouped by plant sex. Sample suffixes are interpreted as XX = female and XY = male.

## 1. Install the software

- **R (required):** use the [official CRAN downloads](https://cran.r-project.org/), choose Windows, macOS, or Linux, and follow the platform instructions. On Windows, choose **Download R for Windows → base**. The workflow was tested with R 4.3.3 on Linux.
- **RStudio Desktop (optional):** install R first, then follow the [official RStudio Desktop installation page](https://posit.co/download/rstudio-desktop/). RStudio provides an editor and console for running the script.
- **Git (required for cloning):** follow the [official Git installation documentation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). On Windows, Git Bash is a convenient terminal for the clone commands below.

Restart your terminal after installation. Check that Git and R are available:

```bash
git --version
Rscript --version
```

If Windows cannot find `Rscript`, use the RStudio instructions below, or add the `bin` directory of your installed R version to your user PATH and reopen the terminal.

## 2. Package setup

**No additional R packages are required.** The script uses only packages supplied with R (`base`, `utils`, `stats`, `graphics`, and `grDevices`). There is no `install.packages()` step and no need to install ggplot2 or tidyverse.

An internet connection is required each time the script runs because it reads the CSV directly from GitHub. Allow several minutes for the approximately 46 MiB download and analysis; the script sets a download timeout of at least 300 seconds.

## 3. Clone and open the analysis

In a terminal:

```bash
git clone https://github.com/kevindragan/Assignment-1.git
cd Assignment-1
```

At the revision tested on October 30, 2026, the repository contained the dataset but **did not contain `plot_REM16_FT1.R`**. Until the script is committed to the repository, download [plot_REM16_FT1.R](https://chatgpt.com/library?file_id=libfile_d622e14f2d9481919eefe05d010f3ec2&account_id=personal) from the accompanying deliverables and save it in the `Assignment-1` root directory. The ChatGPT download link requires access to the file. Alternatively, extract the script from the accompanying workflow ZIP. Save this README in the same directory.

The setup should contain:

- `Assignment-1/README.md`
- `Assignment-1/plot_REM16_FT1.R`
- `Assignment-1/2_Data_RNASeq_Cannabis_Sex.csv` (included by the clone, but not read by this script)

To inspect the code, open `plot_REM16_FT1.R` in RStudio or another text editor.

## 4. Run the analysis

### Option A: terminal

From the `code`  directory, run:

```bash
Rscript --vanilla plot_REM16_FT1.R
```

`--vanilla` prevents saved workspaces and personal R startup files from affecting the run. The script creates `figures/` under the current working directory. To use another output folder:

```bash
Rscript --vanilla plot_REM16_FT1.R results
```

The sole optional argument is the output directory, not a dataset filename.

### Option B: RStudio

1. Open `plot_REM16_FT1.R` using **File → Open File**.
2. Choose **Session → Set Working Directory → To Source File Location** so output files go into the repository folder.
3. In the Console, run:

```r
source("plot_REM16_FT1.R")
```

The script saves figures directly to disk; they need not appear in RStudio's Plots pane. Open the `figures` folder using the Files pane or your file manager.

## 5. Input and data-quality handling

The script reads this exact raw CSV URL:

```r
url <- "https://raw.githubusercontent.com/kevindragan/Assignment-1/refs/heads/main/2_Data_RNASeq_Cannabis_Sex.csv"
```

- Loci are matched by their full locus IDs, while figures use the names REM16 and FT1.
- REM16 is stored as `Cannabis_LOC115699937`. The code removes only the explicit `Cannabis_` prefix before matching.
- FT1 has one missing value, for sample `011_XX`. It remains `NA` in the extracted CSV and is excluded from that gene's box plot and summaries; it is not replaced with zero.
- Duplicate sample names, unexpected sex suffixes, missing or ambiguous target loci, and non-numeric or infinite target expression values trigger errors.
- The CSV does not document units or normalization. Values stay on their supplied scale; no extra log transformation or normalization is applied.

The `main` branch can change. Cloning a specific repository revision does not pin this script's remote input because it still reads `main`. For a fixed analysis, replace `refs/heads/main` in the raw URL with the desired full commit SHA.

## 6. Outputs

| File | Contents |
| --- | --- |
| `REM16_by_sex.png` and `.pdf` | REM16 box plot |
| `FT1_by_sex.png` and `.pdf` | FT1 box plot |
| `REM16_FT1_combined_by_sex.png` and `.pdf` | Both genes with a shared y-axis scale |
| `REM16_FT1_extracted_expression.csv` | Both loci in long format, including missing values and source IDs |
| `expression_summary.csv` | Sample counts, missing counts, medians, quartiles, and ranges |
| `data_quality_notes.txt` | Input URL, assumptions, matched IDs, and missing samples |
| `R_session_info.txt` | R version, platform, and session details |

Points represent samples. Boxes show the middle 50% using R's boxplot hinges, thick lines show medians, and whiskers extend to observations within 1.5 times the box height. All observations, including outliers, are shown as points. Horizontal jitter is reproducible. Running again in the same output folder overwrites the generated files.

For the tested dataset, there are 69 XX and 69 XY samples. REM16 uses all 138 observations; FT1 uses 68 XX and 69 XY observations. These plots are descriptive; the script does not run significance tests.

## 7. Troubleshooting

- **GitHub download fails:** check your internet connection and open the raw CSV URL in a browser. Confirm that the repository/file still exists. If the timeout is insufficient, increase `300` in the script's `options(timeout = ...)` line.
- **Cannot find the script:** verify that it was downloaded into the repository root, that its extension is `.R` rather than `.R.txt`, and that the terminal is in that directory.
- **Cannot create outputs:** use a folder where you have write permission. Avoid overwriting files that are open in another program.
- **Data validation error:** inspect the error and upstream CSV; do not bypass checks or replace missing values with zeros.

## 8. Fresh-clone verification

See `workflow_test_report.txt` in the accompanying workflow ZIP for the tested revision, environment, commands, and comparison results. The verification explicitly includes adding the supplied script to the fresh clone because the remote repository did not yet contain it. No files were pushed to GitHub.
