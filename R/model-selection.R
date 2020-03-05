
## Model selection ----

#' Extract the Best Model
#'
#' Extracts the best model from the `auto_*()` search procedure.
#'
#' @param x   An `auto_edina` object
#' @param ic  Selection criteria
#' @param ... Not used.
#'
#' @return
#' An `edina` object
#'
#' @export
#' @rdname best_model
best_model = function(x, ...) {
    UseMethod("best_model")
}

#' @export
#' @rdname best_model
best_model.auto_edina = function(x, ic = c("ppp", "bic", "dic"), ...) {
    ic = tolower(ic)
    ic = match.arg(ic)

    x$edina_models[[which.min(x$criterion[,ic])]]
}

#' @export
best_model.default = function(x, ...) {
    stop_bad_class(x, "auto_edina")
}


### PPP Criteria ----

#' Model Heuristic used for Model Selection
#'
#' Computes the model heuristic for model selection.
#' @inheritParams summary.edina
#' @return A `double` that is the mean.
#' @export
PPP = function(object, ...) {
    UseMethod("PPP")
}

PPP.edina = function(object, alpha = 0.05, ...) {
    or_tested = object$or_tested

    mean(or_tested[upper.tri(or_tested)] < alpha |
             or_tested[upper.tri(or_tested)] > (1-alpha))
}

#' Compute the Deviance Information Criterion (DIC)
#'
#' Calculate DIC for EDINA models.
#'
#' @param object An `edina` object
#' @param ... Not used.
#' @rdname DIC
#' @export
DIC = function(object, ...) {
    UseMethod("DIC")
}

#' @rdname DIC
#' @export
DIC.edina = function(object, ...) {

    # LogLikelihood at the Mean of the Posterior Distributioon
    L = object$loglike_pmean

    # Number of parameters in the model
    P = 2 * (L - (1 / object$chain_length * object$loglike_summed))

    -2 * (L - P)
}


## 2 * K - I_K fixed allothers to 1's. Then estimate R* matrix and the J pi*

#' Calculate BIC for EDINA models.
#' @param object An `edina` object
#' @param ... Not used.
#' @export
#' @importFrom stats BIC
BIC.edina = function(object, ...) {
    # K number of attributes and J number of items (count only one slipping/guessing)?
    # -2 * LogLike + ln(n) * (k + j)
    -2*object$loglike_pmean + log(object$n)*((object$k+2)*object$j + 2^object$k)
}