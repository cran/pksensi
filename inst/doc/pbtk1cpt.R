## ----setup, include = FALSE----------------------------------------------
library(pksensi)
#mcsim_install()

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.height=4, 
  fig.width=6
)

fn = local({ # not used function for fig caption
  i = 0
  function(x) {
    i <<- i + 1
    paste('Figure ', i, ': ', x, sep = '')
  }
})


## ---- eval=F-------------------------------------------------------------
#  pbtk1cpt_model()
#  cat(readLines("pbtk1cpt.model"), sep = "\n")

## ---- eval=F-------------------------------------------------------------
#  mName <- "pbtk1cpt"
#  compile_model(mName, application = "R")
#  source(paste0(mName, "_inits.R"))

## ---- eval=F-------------------------------------------------------------
#  parms <- initParms()
#  parms["vdist"] <- 0.74
#  parms["ke"] <- 0.28
#  parms["kgutabs"] <- 2.18
#  initState <- initStates(parms=parms)
#  initState["Agutlument"] <- 10

## ---- eval=F-------------------------------------------------------------
#  parms

## ---- eval=F-------------------------------------------------------------
#  initState

## ---- eval=F-------------------------------------------------------------
#  Outputs

## ---- eval=F-------------------------------------------------------------
#  times <- seq(from = 0.01, to = 24.01, by = 1)
#  y <- deSolve::ode(initState, times, func = "derivs", parms = parms,
#                    dllname = mName, initfunc = "initmod", nout = 1, outnames = Outputs)

## ---- eval=F, fig.cap = 'Figure 1. Simulation results of one-compartment PBTK model.'----
#  plot(y)

## ---- eval=F-------------------------------------------------------------
#  LL <- 0.5
#  UL <- 1.5
#  q <- "qunif"
#  q.arg <- list(list(min = parms["vdist"] * LL, max = parms["vdist"] * UL),
#               list(min = parms["ke"] * LL, max = parms["ke"] * UL),
#               list(min = parms["kgutabs"] * LL, max = parms["kgutabs"] * UL))
#  set.seed(1234)
#  params <- c("vdist", "ke", "kgutabs")
#  x <- rfast99(params, n = 200, q = q, q.arg = q.arg, replicate = 20)

## ---- eval=F-------------------------------------------------------------
#  out <- solve_fun(x, times, initState = initState, outnames = Outputs, dllname = mName)

## ---- eval=F, fig.cap = 'Figure 2. Time-dependent sensitivity indices of the plasma concentration estimated from one-compartment PBTK model during 24 hour time period intake.'----
#  plot(out)

## ---- eval=F, fig.cap = 'Figure 3. The relationship between model parameter and estimated concentration under the time-point of 0.01, 2.01, and 24.01 hr'----
#  par(mfrow = c(3,3), mar = c(2,2,2,2), oma = c(2,2,1,1))
#  plot(x$a[,1,"vdist"], out$y[,1,"0.01",], main = "vdist")
#  text(1, .7, "t=0.01",cex = 1.2)
#  plot(x$a[,1,"ke"], out$y[,1,"0.01",], main = "ke")
#  plot(x$a[,1,"kgutabs"], out$y[,1,"0.01",], main = "kgutabs")
#  plot(x$a[,1,"vdist"], out$y[,1,"2.01",])
#  text(1, 18, "t=2.01",cex = 1.2)
#  plot(x$a[,1,"ke"], out$y[,1,"2.01",])
#  plot(x$a[,1,"kgutabs"], out$y[,1,"2.01",])
#  plot(x$a[,1,"vdist"], out$y[,1,"24.01",])
#  text(1, .7, "t=24.01",cex = 1.2)
#  plot(x$a[,1,"ke"], out$y[,1,"24.01",])
#  plot(x$a[,1,"kgutabs"], out$y[,1,"24.01",])
#  mtext("parameter", SOUTH<-1, line=0.4, outer=TRUE)
#  mtext("Ccompartment", WEST<-2, line=0.4, outer=TRUE)

## ---- eval=F-------------------------------------------------------------
#  dim(x$a)

## ---- eval=F-------------------------------------------------------------
#  dim(out$y)

## ---- eval=F-------------------------------------------------------------
#  check(out, SI.cutoff = 0.5)

## ---- eval=F-------------------------------------------------------------
#  system.time(y<-solve_fun(x, times, initState = initState, outnames = Outputs, dllname = mName))

## ---- eval=F-------------------------------------------------------------
#  compile_model(mName, application = "mcsim")

## ---- eval=F-------------------------------------------------------------
#  conditions <- c("Agutlument = 10") # Set the initial state of Agutlument = 10
#  system.time(y<-solve_mcsim(x, mName = mName,
#                             params = params,
#                             vars = Outputs,
#                             time = times,
#                             condition = conditions))

