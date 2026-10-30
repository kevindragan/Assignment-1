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

Open a terminal (Git Bash on Windows) in the folder where you want to store the project:

```bash
git clone https://github.com/kevindragan/Assignment-1.git
cd Assignment-1
```

The analysis script is already included at `Code/plot_REM16_FT1.R`. Folder names are case-sensitive on Linux: use `Code`, not `code`.

| Repository path | Purpose |
| --- | --- |
| `Code/plot_REM16_FT1.R` | Executable analysis script |
| `2_Data_RNASeq_Cannabis_Sex.csv` | Dataset; the script reads its online GitHub copy |
| `Figures/` | Previously saved PDF figures |
| `Question_1/`, `Question_2/`, `Question_4/` | Other assignment materials |

Open `Code/plot_REM16_FT1.R` in RStudio using **File → Open File** to inspect the analysis.

## 4. Run the analysis

### Option A: terminal

From the repository root (`Assignment-1`), run:

```bash
Rscript --vanilla Code/plot_REM16_FT1.R results
```

The script creates `results/` in the repository root and writes all 10 outputs there. No local dataset path is needed. `--vanilla` prevents saved workspaces and personal R startup files from affecting the run.

The optional argument `results` is the output directory. Use a different name to keep separate runs. If omitted, the script uses `figures/` in the current working directory. Explicitly using `results` avoids confusing or overwriting the repository's existing `Figures/` directory on systems where filenames are case-insensitive, including typical Windows installations.

### Option B: RStudio

1. Choose **File → New Project → Existing Directory** and select the cloned `Assignment-1` folder. This creates a local RStudio project and opens it at the repository root.
2. Open `Code/plot_REM16_FT1.R` from the Files pane or **File → Open File**.
3. Open RStudio's **Terminal** tab (not the R Console). Make sure it is in the `Assignment-1` root folder, then run:

```bash
Rscript --vanilla Code/plot_REM16_FT1.R results
```

If `Rscript` is not on your PATH, run this equivalent command in the **R Console**, with the working directory set to the repository root:

```r
system2(file.path(R.home("bin"), "Rscript"),
        c("--vanilla", "Code/plot_REM16_FT1.R", "results"))
```

The plots are saved directly to disk, so they need not appear in RStudio's Plots pane. Open `results/` in the Files pane or your file manager to view the PNGs, PDFs, and tables.

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
- **Cannot find the script:** verify that the terminal is in the `Assignment-1` root and that `Code/plot_REM16_FT1.R` exists. Preserve the capital C in `Code`.
- **Cannot create outputs:** use a folder where you have write permission. Avoid overwriting files that are open in another program.
- **Data validation error:** inspect the error and upstream CSV; do not bypass checks or replace missing values with zeros.

## 8. Fresh-clone verification

Tested on October 30, 2026 from a new clone of repository commit `2b0c254153715a391f00552c0c2fb2b529baa6cb`, using Linux, R 4.3.3, Git 2.51.1, an empty user package library, and `--vanilla`.

The repository's script was run unchanged, with no manually added script and no extra R packages. The documented root-directory command generated all 10 expected files in `results/`. All three PNGs and both CSV tables matched the previously verified results byte-for-byte. The R Console `system2()` command was also tested in a clean R session. RStudio's graphical interface and Windows/macOS installation steps were not tested.

The test reads the live GitHub CSV, as the script specifies; a fixed repository checkout alone does not pin that remote input. No changes were pushed to GitHub.
