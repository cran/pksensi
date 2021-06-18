## ----setup, include = FALSE---------------------------------------------------
library(pksensi)
#mcsim_install()

knitr::opts_chunk$set(
  eval = F,
  dev = "png",
  dpi = 200,
  fig.align = "center",
  fig.width = 7,
  out.width = "90%",
  fig.height = 4,
  comment = "#>"
)

## -----------------------------------------------------------------------------
#  pbtk1cpt <- function(t, state, parameters) {
#    with(as.list(c(state, parameters)), {
#      dAgutlument = - kgutabs * Agutlument
#      dAcompartment = kgutabs * Agutlument - ke * Acompartment
#      dAmetabolized = ke * Acompartment
#      Ccompartment = Acompartment / vdist * BW;
#      list(c(dAgutlument, dAcompartment, dAmetabolized),
#           "Ccompartment" = Ccompartment)
#    })
#  }

## ---- warning=F---------------------------------------------------------------
#  library(httk)
#  pars1comp <- (parameterize_1comp(chem.name = "acetaminophen"))
#  unlist(pars1comp)

## -----------------------------------------------------------------------------
#  parms <- c(vdist = pars1comp$Vdist,
#             ke = pars1comp$kelim,
#             kgutabs = pars1comp$kgutabs,
#             BW = pars1comp$BW)
#  initState <- c(Agutlument = 10, Acompartment = 0, Ametabolized = 0)
#  parms

## -----------------------------------------------------------------------------
#  library(deSolve)
#  t <- seq(from = 0.01, to = 24.01, by = 1)
#  y <- ode(y = initState, times = t, func = pbtk1cpt, parms = parms)

## ---- fig.height=6, fig.width=5-----------------------------------------------
#  plot(y)

## -----------------------------------------------------------------------------
#  params <- c("vdist", "ke", "kgutabs", "BW")
#  q <- c("qunif", "qunif", "qunif", "qnorm")
#  q.arg <- list(list(min = pars1comp$Vdist / 2, max = pars1comp$Vdist * 2),
#                list(min = pars1comp$kelim / 2, max = pars1comp$kelim * 2),
#                list(min = pars1comp$kgutabs / 2, max = pars1comp$kgutabs * 2),
#                list(mean = pars1comp$BW, sd = 5))
#  q.arg

## -----------------------------------------------------------------------------
#  set.seed(1234)
#  x <- rfast99(params, n = 200, q = q, q.arg = q.arg, replicate = 10)

## -----------------------------------------------------------------------------
#  dim(x$a)

## ---- fig.height=5------------------------------------------------------------
#  par(mfrow=c(4,4),mar=c(0.8,0.8,0.8,0),oma=c(4,4,2,1), pch =".")
#  for (j in c("vdist", "ke", "kgutabs", "BW")) {
#    if ( j == "BW") {
#      plot(x$a[,1,j], ylab = "BW")
#    } else plot(x$a[,1,j], xaxt="n", ylab = "")
#    for (i in 2:3) {
#    if ( j == "BW") {
#      plot(x$a[,i,j], ylab = "", yaxt="n")
#      } else plot(x$a[,i,j], xaxt="n", yaxt="n", ylab = "")
#    }
#    hist <- hist(x$a[,,j], plot=FALSE,
#                 breaks=seq(from=min(x$a[,,j]), to=max(x$a[,,j]), length.out=20))
#    barplot(hist$density, axes=FALSE, space=0, horiz = T, main = j)
#  }
#  mtext("Model evaluation", SOUTH<-1, line=2, outer=TRUE)

## -----------------------------------------------------------------------------
#  outputs <- c("Ccompartment", "Ametabolized")
#  out <- solve_fun(x, time = t, func = pbtk1cpt, initState = initState, outnames = outputs)

## -----------------------------------------------------------------------------
#  plot(out)

## -----------------------------------------------------------------------------
#  plot(out, vars = "Ametabolized")

## ---- fig.height=5------------------------------------------------------------
#  par(mfcol=c(4,4),mar=c(0.8,0.8,0,0),oma=c(4,4,2,1), pch = ".")
#  plot(x$a[,1,"vdist"], out$y[,1,"0.01",1], xaxt="n", main = "\nvdist")
#  plot(x$a[,1,"vdist"], out$y[,1,"2.01",1], xaxt="n")
#  plot(x$a[,1,"vdist"], out$y[,1,"6.01",1], xaxt="n")
#  plot(x$a[,1,"vdist"], out$y[,1,"24.01",1])
#  for (j in c("ke", "kgutabs", "BW")){
#    for (k in c("0.01", "2.01", "6.01", "24.01")){
#      if (k == "0.01") {
#        plot(x$a[,1,j], out$y[,1,k,1], yaxt = "n", xaxt="n", main = paste0("\n", j))
#      } else if (k == "24.01") {
#        plot(x$a[,1,j], out$y[,1,k,1], yaxt = "n")
#        } else plot(x$a[,1,j], out$y[,1,k,1], xaxt = "n", yaxt = "n")
#    }
#  }
#  mtext("Parameter", SOUTH<-1, line=2, outer=TRUE)
#  mtext("Ccompartment", WEST<-2, line=2, outer=TRUE)

## -----------------------------------------------------------------------------
#  dim(out$y)

## -----------------------------------------------------------------------------
#  check(out, SI.cutoff = 0.05)

## -----------------------------------------------------------------------------
#  pbtk1cpt_model()
#  cat(readLines("pbtk1cpt.model"), sep = "\n")

## ---- message=FALSE, warning=FALSE--------------------------------------------
#  mName <- "pbtk1cpt"
#  compile_model(mName, application = "R")

## -----------------------------------------------------------------------------
#  source(paste0(mName, "_inits.R"))

## -----------------------------------------------------------------------------
#  parms <- initParms()
#  parms["vdist"] <- pars1comp$Vdist
#  parms["ke"] <- pars1comp$kelim
#  parms["kgutabs"] <- pars1comp$kgutabs
#  parms["BW"] <- pars1comp$BW
#  initState <- initStates(parms=parms)
#  initState["Agutlument"] <- 10

## -----------------------------------------------------------------------------
#  parms

## -----------------------------------------------------------------------------
#  initState

## -----------------------------------------------------------------------------
#  Outputs

## -----------------------------------------------------------------------------
#  t <- seq(from = 0.01, to = 24.01, by = 1)
#  y <- ode(y = initState, times = t, func = "derivs", parms = parms,
#           dllname = mName, initfunc = "initmod",
#           nout = 1, outnames = Outputs)

## -----------------------------------------------------------------------------
#  head(y)

## -----------------------------------------------------------------------------
#  # Define parameter distribution
#  q <- c("qunif", "qunif", "qunif", "qnorm")
#  q.arg <- list(list(min = parms["vdist"] / 2, max = parms["vdist"] * 2),
#               list(min = parms["ke"] / 2, max = parms["ke"] * 2),
#               list(min = parms["kgutabs"] / 2, max = parms["kgutabs"] * 2),
#               list(mean = parms["BW"], sd = 5))
#  params <- c("vdist", "ke", "kgutabs", "BW")
#  
#  # Generate parameter matrix
#  set.seed(1234)
#  x <- rfast99(params, n = 200, q = q, q.arg = q.arg, replicate = 20)

## -----------------------------------------------------------------------------
#  outputs <- c("Ccompartment", "Ametabolized")
#  out <- solve_fun(x, time = t, initState = initState, outnames = outputs, dllname = mName)
#  check(out)

## -----------------------------------------------------------------------------
#  system.time(out<-solve_fun(x, t, initState = initState, outnames = Outputs, dllname = mName))

## ---- message=F, warning=F----------------------------------------------------
#  compile_model(mName, application = "mcsim")

## -----------------------------------------------------------------------------
#  conditions <- c("Agutlument = 10")
#  system.time(out <- solve_mcsim(x, mName = mName, params = params,
#                                 vars = Outputs, time = t,
#                                 condition = conditions))

## -----------------------------------------------------------------------------
#  sessionInfo()

