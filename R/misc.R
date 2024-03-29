#' @title Return the value of 'lassie' object
#'
#' @description Subroutine for \code{\link[zebu]{lassie}} methods. Tries to retrieve a value from a \code{\link[zebu]{lassie}} object
#' and gives an error if value does not exist.
#'
#' @param x \code{\link[zebu]{lassie}} S3 object.
#' @param what_x vector specifying values to be returned:
#' \itemize{
#' \item 'local': local association measure values (default).
#' \item 'obs': observed probabilities.
#' \item 'exp': expected probabilities.
#' \item 'local_p': p-value of local association (after running \code{\link[zebu]{permtest}} or \code{\link[zebu]{chisqtest}}).
#' }
#'
#' @return Corresponding array contained in \code{\link[zebu]{lassie}} object.
#'
#' @examples
#' las <- lassie(trees)
#' las_array <- lassie_get(las, 'local')
#'
#' @export
#'
lassie_get <- function(x,
                       what_x) {

  if (length(what_x) != 1 || ! what_x %in% c("local", "obs", "exp", "local_p")) {
    stop("Invalid argument: choose one from\n 'local': Local association measure\n 'obs': Observed multivariate probabilities\n 'exp': Expected multivariate probabilities (independence)\n 'local_p: p-value of local association (after running permtest or chisqtest)")
  }
  if (! ("permtest" %in% class(x) | "chisqtest" %in% class(x)) && any(c("local_p") %in% what_x)) {
    stop("Invalid 'what' argument: 'local_p' is only available after running permtest or chisqtest")
  }

  if (what_x == "local") {
    x$local
  } else if (what_x == "obs") {
    x$prob$observed
  } else if (what_x == "exp") {
    x$prob$exp
  } else if (what_x == "local_p") {
    x$local_p
  }
}

# Returns full local association measure name used in lassie object.
measure_name <- function(x) {
  measure <- x$lassie_params[["measure"]]
  if (measure == "z") {
    "Ducher's Z"
  } else if (measure == "d") {
    "Lewontin's D"
  } else if (measure == "pmi") {
    "Pointwise Mutual Information"
  } else if (measure == "npmi") {
    "Normalized Pointwise Mutual Information (Bouma)"
  } else if (measure == "npmi2") {
    "Normalized Pointwise Mutual Information (Multivariate)"
  } else if (measure == "chisq") {
    "Chi-squared Residuals"
  } else {
    stop("Invalid 'measure' argument.")
  }
}


# Generate comments for header of write.lassie file
generate_comments <- function(x) {
  com <- paste0("# File generated by the zebu R package (", Sys.time(), ")\n",
                "# https://github.com/oliviermfmartin/zebu\n", "#\n", "# Name of association measure: ",
                measure_name(x), "\n", "# Global association value: ", x$global)
  if ("permtest" %in% class(x) | "chisqtest" %in% class(x)) {
    com <- paste0(com, "\n#\n", "# Permutation test parameters\n", "# Number of iterations: ",
                  x$perm_params$nb, "\n", "# P-value adjustment method: ", x$perm_params$p_adjust)
  }
  com <- paste0(com, "\n#")
  com
}

.compute_expected_probability <- function(margins) {
  Reduce(outer, margins)
}

.compute_theoretical_max_prob <- function(margins) {
  Reduce(function(x, y) outer(x, y, pmin), margins)
}

.compute_theoretical_min_prob <- function(margins) {
  M <- length(margins)
  out <- Reduce(function(x, y) outer(x, y, `+`), margins)
  out <- out - M + 1
  out[out<0] <- 0
  out
}
