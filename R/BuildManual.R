#' @importFrom tools texi2pdf
#'
NULL


#' Create a reference manual for an R package
#'
#' This function takes as input the name of the package and the path where its
#' folder is located. It assumes that the package folder contains a DESCRIPTION
#' file as well as a man folder with .Rd files generated using roxygen.
#' Currently, graphics and special fonts (i.e., Cyrillic) are not supported
#'
#' @param packageName The package name
#'
#' @param packagePath The path where the package is located
#'
#' @details This function uses \code{tools:::.DESCRIPTION_to_latex()} and \code{tools:::.Rdfiles2tex}, non-exported functions from \pkg{tools}.
#'
#' @export
#'
buildManual <- function (packageName, packagePath = '../')
{
  packageDir <- paste0(packagePath, packageName)
  out <- file(packageName, 'wt')
  writeLines("\\nonstopmode{}", out)
  cat("\\documentclass[", Sys.getenv("R_PAPERSIZE"), "paper]{book}\n",
      "\\usepackage[", Sys.getenv("R_RD4PDF", "times,inconsolata,hyper"),
      "]{Rd}\n", sep = "", file = out)

  writeLines("\\usepackage{makeidx}", out)
  inputenc <- Sys.getenv("RD2PDF_INPUTENC", "inputenc")
  setEncoding <- paste0("\\usepackage[", 'utf8', "]{", inputenc, "} % @SET ENCODING@")
  writeLines(c(setEncoding, if (inputenc == "inputenx") "\\IfFileExists{ix-utf8enc.dfu}{\\input{ix-utf8enc.dfu}}{}"
               , "\\makeindex{}", "\\begin{document}"), out)

  title <- paste0("Package `", packageName, "'")

  cat("\\chapter*{}\n", "\\begin{center}\n", "{\\textbf{\\huge ",
      title, "}}\n", "\\par\\bigskip{\\large \\today}\n",
      "\\end{center}\n", sep="", file=out)

  tools:::.DESCRIPTION_to_latex(file.path(packageDir, "DESCRIPTION"), out)
  toc <- "\\Rdcontents{Contents}"

  writeLines(toc, out)
  res <- tools:::.Rdfiles2tex(packageDir, out, encoding='UTF-8', outputEncoding='UTF-8', append=TRUE)
  writeLines("\\printindex{}", out)
  writeLines("\\end{document}", out)
  close(out)
  tools::texi2pdf(packageName, clean=TRUE)
  invisible(file.remove(packageName))
}


