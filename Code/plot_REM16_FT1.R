# Run: Rscript plot_REM16_FT1.R [output_directory]
# Base R only; no packages need to be installed.
args <- commandArgs(trailingOnly = TRUE)
url <- "https://raw.githubusercontent.com/kevindragan/Assignment-1/refs/heads/main/2_Data_RNASeq_Cannabis_Sex.csv"
input <- url
out <- if (length(args) >= 1) args[1] else "figures"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
# Read the raw GitHub CSV directly; no local input file is required.
# The file is about 46 MiB, so allow extra time for slower connections.
options(timeout = max(300, getOption("timeout")))
d <- tryCatch(
  read.csv(url, check.names = FALSE, stringsAsFactors = FALSE,
           colClasses = "character", na.strings = c("NA", "")),
  error = function(e) stop("Could not read the GitHub CSV: ", conditionMessage(e),
                           ". Check the URL and internet connection.", call. = FALSE)
)
if (ncol(d) < 2) stop("Expected locus IDs followed by sample columns.")
sample <- names(d)[-1]
if (anyDuplicated(sample) || any(!grepl("^[0-9]+_(XX|XY)$", sample)))
  stop("Duplicate sample names or unexpected sex suffix; check metadata.")
# Interpret XX as female and XY as male, based on sample suffixes.
# These are inferred sex groups, not independently verified phenotypes.
# Assigns sex groups
sex <- factor(ifelse(grepl("_XX$", sample), "Female (XX)", "Male (XY)"),
              levels = c("Female (XX)", "Male (XY)"))
raw_id <- trimws(d[[1]])
# Genuine structure issue: REM16 is stored as Cannabis_LOC115699937.
# Remove only the explicit prefix, then match the complete locus ID.
id <- sub("^Cannabis_", "", raw_id)
targets <- c(REM16 = "LOC115699937", FT1 = "LOC115696989")
#create character vector
audit <- c(paste("Input URL:", input),
           paste("Dataset:", nrow(d), "rows;", length(sample), "samples"),
           "Sex inferred from sample suffixes: XX = female; XY = male.",
           "Expression units/normalization are not documented in the CSV.",
           "Original values retained: no log transform, normalization, or imputation.")
# extract genes and validation
rows <- lapply(names(targets), function(g) {
  i <- which(!is.na(id) & id == targets[g])
  if (length(i) != 1) stop(paste(g, "must match exactly one locus row; found", length(i)))
  raw <- unlist(d[i, -1], use.names = FALSE)
  v <- suppressWarnings(as.numeric(raw))
  if (any(!is.na(raw) & is.na(v))) stop(paste("Non-numeric expression in", g))
  if (any(!is.na(v) & !is.finite(v))) stop(paste("Non-finite expression in", g))
  audit <<- c(audit, paste(g, ": matched", raw_id[i], "to", targets[g]),
             paste(g, "missing samples:", paste(sample[is.na(v)], collapse = ", ")))
  data.frame(gene = g, locus_id = unname(targets[g]), source_id = raw_id[i],
             sample_id = sample, sex = sex, expression = v)
})
dat <- do.call(rbind, rows)
# saves extracted data
write.csv(dat, file.path(out, "REM16_FT1_extracted_expression.csv"), row.names = FALSE, na = "NA")
#summary table
summ <- do.call(rbind, lapply(split(dat, list(dat$gene, dat$sex)), function(z) {
  v <- z$expression[!is.na(z$expression)]
  if (!length(v)) stop("A gene/sex group has no observations.")
  data.frame(gene = z$gene[1], sex = z$sex[1], n = length(v),
             missing = sum(is.na(z$expression)), median = median(v),
             Q1 = unname(quantile(v, .25)), Q3 = unname(quantile(v, .75)),
             min = min(v), max = max(v))
}))
write.csv(summ, file.path(out, "expression_summary.csv"), row.names = FALSE)
writeLines(audit, file.path(out, "data_quality_notes.txt"))
colors <- c("#007F89", "#C66B28")
draw_panel <- function(g, limits) {
  z <- dat[dat$gene == g & !is.na(dat$expression), ]
  counts <- table(z$sex)
  boxplot(expression ~ sex, data = z, ylim = limits, axes = FALSE,
          col = adjustcolor(colors, .25), border = colors, outline = FALSE,
          boxwex = .46, medlwd = 2.3, whisklty = 1, staplewex = .65,
          xlab = "", ylab = "Expression (supplied dataset scale)", main = g,
          cex.main = 1.5, cex.lab = 1.05)
  abline(h = axTicks(2), col = "#E6E9EC", lwd = .7)
  # Redraw boxes over the light reference grid.
  boxplot(expression ~ sex, data = z, add = TRUE, axes = FALSE,
          col = adjustcolor(colors, .25), border = colors, outline = FALSE,
          boxwex = .46, medlwd = 2.3, whisklty = 1, staplewex = .65)
  set.seed(42)
  points(jitter(as.integer(z$sex), amount = .12), z$expression,
         pch = 21, bg = adjustcolor(colors[as.integer(z$sex)], .65),
         col = "white", lwd = .35, cex = .85)
  axis(1, at = 1:2, labels = paste0(levels(sex), "\nn = ", counts),
       tick = FALSE, line = .4, cex.axis = .95)
  axis(2, las = 1, col = "#8B949E", col.axis = "#34404A")
  mtext("Plant sex", side = 1, line = 3.5)
  box(bty = "l", col = "#8B949E")
}
make_figure <- function(genes, filename) {
  combined <- length(genes) > 1
  # Shared y limits in combined figure permit direct comparison.
  values <- dat$expression[dat$gene %in% genes]
  r <- range(values, na.rm = TRUE)
  limits <- r + c(-1, 1) * max(diff(r) * .09, .1)
  for (format in c("png", "pdf")) {
    path <- file.path(out, paste0(filename, ".", format))
    if (format == "png") png(path, width = if(combined) 11 else 6.5,
                             height = 6.4, units = "in", res = 220)
    else pdf(path, width = if(combined) 11 else 6.5, height = 6.4)
    par(mfrow = c(1, length(genes)), mar = c(5.9, 5.2, 3.5, 1.4),
        oma = c(3, 0, if(combined) 2 else 0, 0), family = "sans",
        col.main = "#192F3D", fg = "#34404A")
    for (g in genes) draw_panel(g, limits)
    if (combined) mtext("Cannabis gene expression by plant sex", outer = TRUE,
                        side = 3, line = .3, font = 2, cex = 1.2)
    mtext("Points = samples; boxes = IQR; line = median; whiskers = up to 1.5 x IQR.",
          side = 1, outer = TRUE, line = .5, cex = .75)
    mtext("Units/normalization unspecified; original scale retained. Missing values excluded.",
          side = 1, outer = TRUE, line = 1.7, cex = .75)
    dev.off()
  }
}
make_figure("REM16", "REM16_by_sex")
make_figure("FT1", "FT1_by_sex")
make_figure(c("REM16", "FT1"), "REM16_FT1_combined_by_sex")
capture.output(sessionInfo(), file = file.path(out, "R_session_info.txt"))
print(summ)
cat(paste(audit, collapse = "\n"), "\n")
