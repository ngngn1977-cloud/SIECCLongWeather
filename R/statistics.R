#' Ordinary least-squares trend
#' @export
ols_fit <- function(time, value) {
  fit <- stats::lm(value ~ time)
  list(fit = fit, slope_year = unname(stats::coef(fit)["time"]), slope_decade = unname(stats::coef(fit)["time"]) * 10)
}

.siecc_hac_fit <- function(time, value) {
  .siecc_require("sandwich"); .siecc_require("lmtest")
  n <- length(value); lag_nw <- max(1L, floor(4 * (n / 100)^(2 / 9)))
  fit <- stats::lm(value ~ time)
  covariance <- sandwich::NeweyWest(fit, lag = lag_nw, prewhite = FALSE, adjust = TRUE)
  coefficient <- lmtest::coeftest(fit, vcov. = covariance)["time", ]
  critical <- stats::qt(0.975, df = n - 2L)
  list(n = n, lag = lag_nw, slope_year = unname(coefficient[1]),
       slope_decade = unname(coefficient[1]) * 10, se_decade = unname(coefficient[2]) * 10,
       ci_low_decade = (unname(coefficient[1]) - critical * unname(coefficient[2])) * 10,
       ci_high_decade = (unname(coefficient[1]) + critical * unname(coefficient[2])) * 10,
       p = unname(coefficient[4]))
}

.siecc_gls_fit <- function(time, value) {
  .siecc_require("nlme")
  d <- data.frame(time = time, value = value)
  fit <- nlme::gls(value ~ time, data = d, correlation = nlme::corAR1(form = ~ time), method = "ML")
  tt <- summary(fit)$tTable["time", ]; critical <- stats::qt(0.975, df = length(value) - 2L)
  phi <- as.numeric(stats::coef(fit$modelStruct$corStruct, unconstrained = FALSE))
  list(slope_decade = unname(tt["Value"]) * 10, se_decade = unname(tt["Std.Error"]) * 10,
       ci_low_decade = (unname(tt["Value"]) - critical * unname(tt["Std.Error"])) * 10,
       ci_high_decade = (unname(tt["Value"]) + critical * unname(tt["Std.Error"])) * 10,
       p = unname(tt["p-value"]), phi = phi)
}

.siecc_theilsen_fit <- function(value) {
  .siecc_require("trend"); z <- trend::sens.slope(value, conf.level = 0.95)
  list(slope_decade = unname(z$estimates[1]) * 10,
       ci_low_decade = unname(z$conf.int[1]) * 10,
       ci_high_decade = unname(z$conf.int[2]) * 10)
}

#' Autocorrelation-adjusted modified Mann-Kendall sensitivity
#' @export
modified_mk_fit <- function(value) {
  .siecc_require("modifiedmk"); z <- modifiedmk::mmkh(as.numeric(value))
  p <- as.numeric(z[["new P-value"]])
  if (!is.finite(p)) stop("Modified MK did not return a finite corrected p-value", call. = FALSE)
  list(method = "modifiedmk::mmkh_Hamed_Rao_variance_correction", p = p,
       role = "SENSITIVITY_HAC_REMAINS_PRIMARY")
}

.siecc_legacy_mk_fit <- function(value) {
  .siecc_require("trend"); z <- trend::mk.test(value, alternative = "two.sided", continuity = TRUE)
  list(tau = unname(z$estimates["tau"]), p = unname(z$p.value), role = "LEGACY_REFERENCE_ONLY")
}

.siecc_gam_fit <- function(time, value) {
  .siecc_require("mgcv"); d <- data.frame(value = value, time = time)
  linear <- stats::lm(value ~ time, data = d)
  gam <- mgcv::gam(value ~ s(time, bs = "cr", k = 6), data = d, method = "ML")
  gs <- summary(gam); edf <- unname(gs$s.table[1, "edf"])
  p_column <- grep("p-value", colnames(gs$s.table), fixed = TRUE)[1]
  p <- unname(gs$s.table[1, p_column]); delta <- stats::AIC(gam) - stats::AIC(linear)
  strong <- is.finite(edf) && edf >= 2 && p < .05 && delta <= -10
  list(fit = gam, edf = edf, p = p, delta_aic = delta, strong = strong,
       classification = if (strong) "STRONG_NONLINEAR_DEPARTURE" else "NO_STRONG_NONLINEAR_DEPARTURE")
}

#' Benjamini-Hochberg adjustment
#' @export
bh_adjust <- function(p) stats::p.adjust(as.numeric(p), method = "BH")

.siecc_descriptives <- function(value, label) {
  data.frame(N = length(value), MEAN = mean(value), SD = stats::sd(value), MEDIAN = stats::median(value),
             IQR = stats::IQR(value), MIN = min(value), MIN_PERIOD = label[which.min(value)][1],
             MAX = max(value), MAX_PERIOD = label[which.max(value)][1], MISSING_N = sum(!is.finite(value)),
             stringsAsFactors = FALSE)
}

#' Climate-change supporting contrasts
#' @export
climate_change_contrasts <- function(time, value) {
  time <- as.integer(time); value <- as.numeric(value)
  period_mean <- function(a, b) mean(value[time >= a & time <= b])
  first <- sort(unique(time))[seq_len(min(10L, length(unique(time))))]
  recent <- utils::tail(sort(unique(time)), min(10L, length(unique(time))))
  data.frame(
    MEAN_1961_1990 = period_mean(1961, 1990),
    MEAN_1991_2020 = period_mean(1991, 2020),
    NORMAL_DIFFERENCE = period_mean(1991, 2020) - period_mean(1961, 1990),
    FIRST_DECADE_MEAN = mean(value[time %in% first]),
    RECENT_DECADE_MEAN = mean(value[time %in% recent]),
    FIRST_RECENT_DIFFERENCE = mean(value[time %in% recent]) - mean(value[time %in% first]),
    stringsAsFactors = FALSE
  )
}

.siecc_analyse_one <- function(period, metric, time, label, value) {
  h <- .siecc_hac_fit(time, value); g <- .siecc_gls_fit(time, value)
  s <- .siecc_theilsen_fit(value); mmk <- modified_mk_fit(value); mk <- .siecc_legacy_mk_fit(value)
  gam <- .siecc_gam_fit(time, value); o <- ols_fit(time, value)
  signs <- sign(c(h$slope_decade, g$slope_decade, s$slope_decade))
  direction <- if (all(signs > 0)) "ALL_INCREASE" else if (all(signs < 0)) "ALL_DECREASE" else "DISAGREEMENT"
  data.frame(PERIOD = period, METRIC = metric, N = length(value), START = label[1], END = utils::tail(label,1),
             OLS_SLOPE_PER_YEAR = o$slope_year, HAC_SLOPE_PER_DECADE = h$slope_decade,
             HAC_SE = h$se_decade, HAC_CI_LOW = h$ci_low_decade, HAC_CI_HIGH = h$ci_high_decade,
             HAC_P = h$p, NEWEY_WEST_LAG = h$lag, GLS_SLOPE_PER_DECADE = g$slope_decade,
             GLS_CI_LOW = g$ci_low_decade, GLS_CI_HIGH = g$ci_high_decade, GLS_P = g$p,
             GLS_AR1_PHI = g$phi, SEN_SLOPE_PER_DECADE = s$slope_decade, SEN_CI_LOW = s$ci_low_decade,
             SEN_CI_HIGH = s$ci_high_decade, MODIFIED_MK_P = mmk$p, LEGACY_MK_P = mk$p,
             GAM_BASIS = "cubic_regression_spline", GAM_K = 6L, GAM_METHOD = "ML_for_AIC_comparability",
             GAM_EDF = gam$edf, GAM_P = gam$p, GAM_DELTA_AIC = gam$delta_aic,
             GAM_CLASSIFICATION = gam$classification, DIRECTION_AGREEMENT = direction,
             stringsAsFactors = FALSE)
}

.siecc_analyse_frame <- function(frame, period) {
  time <- if (period == "ANNUAL") frame$YEAR else frame$WINTER_START_YEAR
  label <- if (period == "ANNUAL") as.character(frame$YEAR) else frame$WINTER
  rows <- lapply(.siecc_metrics, function(metric) .siecc_analyse_one(period, metric, time, label, frame[[metric]]))
  do.call(rbind, rows)
}

.siecc_add_multiplicity_robustness <- function(trends) {
  trends$PERIOD_BH_Q <- stats::ave(trends$HAC_P, trends$PERIOD, FUN = bh_adjust)
  trends$GLOBAL_BH_Q <- bh_adjust(trends$HAC_P)
  trends$ROBUSTNESS_CLASSIFICATION <- vapply(seq_len(nrow(trends)), function(i) {
    other <- sum(c(trends$GLS_P[i] < .05, trends$MODIFIED_MK_P[i] < .05,
                   trends$SEN_CI_LOW[i] > 0 || trends$SEN_CI_HIGH[i] < 0))
    hac_adjusted <- trends$PERIOD_BH_Q[i] < .05 && (trends$HAC_CI_LOW[i] > 0 || trends$HAC_CI_HIGH[i] < 0)
    if (trends$DIRECTION_AGREEMENT[i] == "DISAGREEMENT") "METHOD_DEPENDENT"
    else if (hac_adjusted && other >= 2L) "ROBUST_DIRECTIONAL_AGREEMENT"
    else if (!hac_adjusted && other == 0L) "NO_LINEAR_TREND_EVIDENCE"
    else "METHOD_DEPENDENT"
  }, character(1))
  trends
}
