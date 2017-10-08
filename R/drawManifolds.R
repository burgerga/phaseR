drawManifolds <- function(deriv, y0 = NULL, parameters = NULL, tend = 1000,
                          col = c("green", "red"), add.legend = TRUE, ...){
  if (is.null(y0)){
    y0 <- locator(n = 1)
    y0 <- c(y0$x, y0$y)
  }
  if ((!is.vector(y0)) & (!is.matrix(y0))){
    stop("y0 is not a vector or matrix as required")
  }
  if (is.vector(y0)){
    y0 <- as.matrix(y0)
  }
  if (nrow(y0)*ncol(y0) != 2){
    stop("y0 should be a matrix where nrow(y0)*ncol(y0) = 2 or a vector of length two")
  }
  if (nrow(y0) < ncol(y0)){
    y0 <- transpose(y0)
  }
  if (length(col) != 2){
    if (length(col) == 1){
      col <- rep(col, 2)
    }
    if (length(col) > 2){
      col <- col[1:2]
    }
    print("Note: col has been reset as required")
  }
  if (tend <= 0){
    stop("tend is less than or equal to zero")
  }
  if (!is.logical(add.legend)){
    stop("add.legend must be logical")
  }
  find.ystar   <- findEquilibrium(deriv = deriv, y0 = y0, system = "two.dim",
                                  parameters = parameters, plot.it = FALSE,
                                  summary = FALSE)
  ystar        <- find.ystar$ystar
  jacobian     <- find.ystar$jacobian
  eigenvectors <- find.ystar$eigenvectors
  eigenvalues  <- find.ystar$eigenvalues
  if (eigenvalues[1]*eigenvalues[2] > 0){
    cat("Fixed point is not a saddle \n")
  } else {
    i1         <- which(eigenvalues > 0)
    i2         <- which(eigenvalues < 0)
    v1         <- eigenvectors[, i1]
    v2         <- eigenvectors[, i2]
    eps        <- 1e-2
    ymax       <- 0.5 + max(abs(ystar)) 
    maxtime.1  <- log(2500*ymax)/abs(eigenvalues[i1])
    maxtime.1  <- max(tend, maxtime.1)
    out.1      <- ode(times = seq(0, maxtime.1, 0.05), y = ystar + eps*v1,
                     func = deriv, parms = parameters, method = "ode45")
    lines(out.1[, 2], out.1[, 3], type = "l", col = col[2], ...)
    unstable.1 <- out.1[, 1:3]
    out.2      <- ode(times = seq(0, maxtime.1, 0.05), y = ystar - eps*v1,
                      func = deriv, parms = parameters, method = "ode45")
    lines(out.2[, 2], out.2[, 3], type = "l", col = col[2], ...)
    unstable.2 <- out.2[, 1:3]
    maxtime.2  <- log(2500*ymax)/abs(eigenvalues[i2])
    maxtime.2  <- max(tend, maxtime.2)
    out.3      <- ode(times = -seq(0, maxtime.2, 0.05), y = ystar + eps*v2,
                      func = deriv, parms = parameters, method = "ode45")
    lines(out.3[, 2], out.3[, 3], type = "l", col = col[1], ...)
    stable.1   <- out.3[, 1:3]
    out.4      <- ode(times = -seq(0, maxtime.2, 0.05), y = ystar - eps*v2,
                      func = deriv, parms = parameters, method = "ode45")
    lines(out.4[, 2], out.4[, 3], type = "l", col = col[1], ...)
    stable.2   <- out.4[, 1:3]
    if (add.legend == TRUE){
      legend("topright", c("Stable", "Unstable"), lty = 1, lwd = 1,
             col = col)
    }
    return(list(add.legend = add.legend, col = col, deriv = deriv,
                parameters = parameters, stable.1 = stable.1,
                stable.2 = stable.2, tend = tend, unstable.1 = unstable.1,
                unstable.2 = unstable.2, y0 = y0, ystar = ystar))
  }
}