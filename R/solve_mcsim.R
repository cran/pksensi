#' Solve PK Model Through \pkg{GNU MCSim}
#'
#' Solve the differential equations of time-dependent quantity/concentration in different tissues/compartments
#' through \pkg{GNU MCSim}.
#'
#' This function allows users to use external data file that assigned in \code{setpoint.name} as parameter matrix.
#' If you want to use it, be sure to define \code{n} and \code{setpoint.name}.
#'
#' @param mName a string giving the name of the model or C file (without extension).
#' @param x a list of storing information in the defined sensitivity function.
#' @param mod a list of model and parameters information that is used in solving differential equation.
#' @param monte_carlo a numeric value to define the sample size in Monte Carlo simulation.
#' @param dist a vector of distribution names corresponding to \code{<distribution-name>} in \pkg{GNU MCSim}.
#' @param q.arg a list of shape parameters in the sampling distribution (\code{dist}).
#' @param infile.name a character to assign the name of input file.
#' @param setpoint.name a character to assign the name of file for parameter matrix.
#' @param outfile.name a character to assign the name of output file.
#' @param params a character to assign the testing parameters.
#' @param vars a character or a vector to assign the selected output(s).
#' @param times a numeric vector to define the given time point(s).
#' @param condition a character to set the specific parameter value in the input file.
#' @param rtol an argument passed to the integrator (default 1e-6).
#' @param atol an argument passed to the integrator (default 1e-6).
#' @param generate.infile a logical value to automatically generate the input file.
#' @param tell a logical value to automatically combine the result y to decoupling simulation x.
#' @param parallel a numeric value to assign the number of cores in parallel computing (default is set to 1).
#'
#' @importFrom data.table fread
#' @importFrom data.table fwrite
#' @importFrom foreach foreach
#' @importFrom foreach %dopar%
#' @importFrom parallel makeCluster
#' @importFrom parallel stopCluster
#' @importFrom doParallel registerDoParallel
#'
#' @return The output result is the 4-dimension array with
#' c(model evaluations, replications, time-points, output variables).
#'
#' @examples
#'
#' \dontrun{
#' pbtk1cpt_model()
#' mName <- "pbtk1cpt"
#' compile_model(mName)
#'
#' q <- "qunif"
#' q.arg <- list(list(min = 0.4, max = 1.1),
#'               list(min = 0.1, max = 0.4),
#'               list(min = 1.0, max = 3.0))
#'
#' params <- c("vdist", "ke", "kgutabs")
#'
#' set.seed(1234)
#' x <- rfast99(params = params, n = 200, q = q, q.arg = q.arg, rep = 20)
#'
#' infile.name <- "example.in"
#' outfile.name <- "example.csv"
#' vars <- "Ccompartment"
#'
#' t <- seq(from = 0.25, to = 12.25, by = 0.5)
#'
#' y <- solve_mcsim(x, mName = mName, infile.name = infile.name,
#'                  setpoint.name = "setpoint.dat",
#'                  outfile.name = outfile.name, params = params, vars = vars, time = t,
#'                  condition = "Agutlument = 10")
#' pksim(y)
#' }
#'
#' @export
#' @describeIn solve_mcsim Numerical analysis for the PK model by \pkg{GNU MCSim}.
solve_mcsim <- function(x,
                        mName,
                        infile.name = NULL,
                        outfile.name = NULL,
                        setpoint.name = NULL,
                        params = NULL,
                        vars = NULL,
                        times = NULL,
                        condition = NULL,
                        generate.infile = T,
                        tell = T,
                        rtol = 1e-06,
                        atol = 1e-06,
                        monte_carlo = NULL,
                        dist = NULL,
                        q.arg = NULL,
                        parallel = 1) {

  message(paste0("Starting time: ", Sys.time()))

  if(is.null(infile.name)) infile.name <- "sim.in"
  if(is.null(outfile.name)) outfile.name <- "simmc.out"

  if(generate.infile == T){
    if (is.null(monte_carlo)){
      generate_infile(infile.name = infile.name,
                      outfile.name = outfile.name,
                      params = params,
                      vars = vars,
                      times = times,
                      rtol = rtol, atol = atol,
                      condition = condition)
    } else { # must be Monte Carlo
      generate_infile(infile.name = infile.name,
                      outfile.name = outfile.name,
                      params = params,
                      vars = vars,
                      times = times,
                      rtol = rtol, atol = atol,
                      condition = condition,
                      monte_carlo = monte_carlo, dist = dist, q.arg = q.arg)
    }
  }

  if(is.null(condition) && is.null(setpoint.name) && is.null(monte_carlo)){
    stop("Please assign the setpoint.name (parameter matrix defined in input file)")
  }

  if(!is.null(condition)){
    setpoint.data <- "setpts.out"
  } else setpoint.data <- setpoint.name

  mStr <- strsplit(mName, "/")
  mName <- mStr[[1]][length(mStr[[1]])]
  if (.Platform$OS.type == "unix"){
    mcsim. <- paste0("mcsim.", mName)
  } else if (.Platform$OS.type == "windows"){ # Windows user but not MCSim under R
    mcsim. <- paste0("mcsim.", mName, ".model.exe")
  }

  if(length(mStr[[1]]) != 1) mdir <- paste(mStr[[1]][-length(mStr[[1]])], collapse = "/")
  if(exists("mdir")) mcsim. <- paste0(mdir, "/",mcsim.)

  if(file.exists(mcsim.) == F){ # Design for MCSim under R
    mcsim. <- paste0("mcsim.", mName, ".exe")
    if(file.exists(mcsim.) == F){
      stop(paste0("The ", mcsim., " doesn't exist."))
    }
  }

  #
  if (is.numeric(monte_carlo)){
    n.sample <- monte_carlo
  } else if (!is.null(x$s)){
    n.sample <- length(x$s)
  }

  if (!is.null(params)){
    n.factors <- length(params)
  } else if (!is.null(x$factors)){
    n.factors <- ifelse(class(x$factors) == "character", length(x$factors), x$factors)
  }

  n.time <- ifelse(is.null(times), 1, length(times))
  n.vars <- length(vars)

  #
  is.natural <- function(x)
  {
    x>0 & identical(round(x), x)
  }

  if (is.null(monte_carlo)){ # Remember to define n if used external parameter matrix
    X <- cbind(1, apply(x$a, 3L, c))

    if (is.natural(parallel) && parallel>1) {
      cores <- parallel
      for (i in 1:cores) {
        # input data
        suppressMessages(data.table::fwrite(X[(1+(i-1)*nrow(X)/cores):(i*nrow(X)/cores),],
                                            file = paste0("p", i, ".", setpoint.data), row.names=F, sep="\t"))
        # input file
        tx  <- readLines(infile.name)
        tx2 <- gsub(pattern = setpoint.data, replacement = paste0("p", i, ".", setpoint.data), x = tx)
        tx3 <- gsub(pattern = outfile.name, replacement = paste0("p", i, ".", outfile.name), x = tx2)
        writeLines(tx3, con = paste0("p", i, ".", infile.name))
      }
    } else suppressMessages(data.table::fwrite(X, file=setpoint.data, row.names=F, sep="\t"))
  }


  if(file.exists(mcsim.) == T){
    if(length(mStr[[1]]) == 1){

      message(paste0("Execute: ", "./", mcsim., " ", infile.name))
      if (is.natural(parallel) && parallel>1) {
        cl <- makeCluster(cores)
        registerDoParallel(cl)
        out <- foreach(i = 1:cores) %dopar%
          {
            system( paste0("./", mcsim., " ", paste0("p", i, ".", infile.name)) )
            file.remove(paste0("p", i, ".", infile.name))
            file.remove(paste0("p", i, ".", setpoint.data))
          }
        stopCluster(cl)
      } else {
        system(paste0("./", mcsim., " ", infile.name))
      }
    } else {

      message(paste0("Execute: ", mcsim., " ", infile.name))
      if (parallel) {
        cl <- makeCluster(cores)
        registerDoParallel(cl)
        out <- foreach(i = 1:cores) %dopar%
          {
            system( paste0(mcsim., " ", paste0("p", i, ".", infile.name)) )
            file.remove(paste0("p", i, ".", infile.name))
            file.remove(paste0("p", i, ".", setpoint.data))
          }
        stopCluster(cl)
      } else {
        system(paste0(mcsim., " ", infile.name))

      }
    }
  }

  if (is.natural(parallel) && parallel>1) {
    p.list <- list()
    for (i in 1:cores) {
      p.list[[i]] <- data.table::fread(paste0("p", i, ".", outfile.name), head = T)
      file.remove(paste0("p", i, ".", outfile.name))
    }
  }

  if (is.null(monte_carlo)){rm(X)}

  invisible(gc()); # clean memory

  str <- n.factors + 2

  if (is.natural(parallel) && parallel>1) {
    df <- as.data.frame( do.call(rbind, list(p.list[[1]], p.list[[2]], p.list[[3]], p.list[[4]])) )
  } else df <- as.data.frame(data.table::fread(outfile.name, head = T))

  invisible(gc()); # clean memory

  y <- as.matrix(df[,str:ncol(df)]) # output only

  rm(df)
  invisible(gc()); # clean memory

  #  if (!is.null(x)){
  #    n.rep <- x$rep
  #  } else {
  n.rep <- nrow(y) / (n.sample * n.factors)
  #  }

  if (nrow(y) == n.sample){ # For Monte Carlo
    dim <- c(n.sample, 1, n.time, n.vars)
  } else  dim <- c(n.sample * n.factors, n.rep, n.time, n.vars)

  dim(y)<- dim

  invisible(gc()); # clean memory

  if (length(times) == 1 && length(vars) == 1) {
    dimnames(y)[[3]] <- list(times)
    dimnames(y)[[4]] <- list(vars)
  } else if (length(times) == 1 && length(vars) > 1){
    dimnames(y)[[3]] <- list(times)
    dimnames(y)[[4]] <- vars
  } else {
    dimnames(y)[[3]] <- times
    dimnames(y)[[4]] <- vars
  }

  if (is.null(monte_carlo) && tell == T){
    tell2(x, y)
  }

  #file.remove(setpoint.data)
  message(paste0("Ending time: ", Sys.time()))

  if (is.null(monte_carlo) && tell == T){
    return(x)
  } else return(y)
}

#' @export
#' @describeIn solve_mcsim Generate the \pkg{GNU MCSim} input file.
generate_infile <- function(mod = NULL,
                            infile.name = NULL,
                            outfile.name = NULL,
                            params = NULL, vars, times,
                            condition, rtol = 1e-6, atol = 1e-6,
                            monte_carlo = NULL, dist = NULL, q.arg = NULL){ # Monte Carlo

  if(is.null(infile.name)) infile.name <- "sim.in"
  if(is.null(outfile.name)) outfile.name <- "simmc.out"
  setpoint.data <- "setpts.out"

  # Title
  cat("#---------------------------------------- \n#",
      " ", infile.name , "\n#",
      " (Created by generate_infile)\n#",
      "----------------------------------------", "\n\n",
      file = infile.name, sep = "")
  cat("Integrate (Lsodes, ", rtol, ", ", atol, " , 1);", "\n\n",
      file=infile.name, append=TRUE, sep="")

  if(is.numeric(monte_carlo) & !is.null(params)) { ## Monte Carlo
    cat("MonteCarlo (", "\"", outfile.name, "\"", ",", monte_carlo , ",",
        sample(1:99999, 1), ");\n\n",
        file = infile.name, append = TRUE, sep = "")
    for (i in 1 : length(params)){
      cat("Distrib ( ", params[i], ",", dist[i], ",",
          paste(unlist(q.arg[i]), collapse = ","), ");", "\n",
          file = infile.name, append=TRUE, sep = "")
    }
  } else if (is.null(monte_carlo) & !is.null(params)) { ## sensitivity
    cat("SetPoints (", "\n",
        "\"", outfile.name, "\", \n\"", setpoint.data, "\",\n",
        "0, ", "\n",
        paste(params, collapse = ", "),");\n\n",
        file = infile.name, append = TRUE, sep = "")
    }

  cat("\n#---------------------------------------- \n#",
      " Simulation scenario\n#",
      "----------------------------------------", "\n\n",
      file = infile.name, append = TRUE, sep = "")
  cat("Simulation {", "\n\n", file = infile.name, append = TRUE)

  # Simple ODE simulation
  if(is.null(monte_carlo) & is.null(params)){

    if(is.null(mod)) stop("Please assign object 'mod'")

    initStates <- mod$initStates
    initParms <- mod$initParms
    outs <- mod$outputs

    # Set init states
    cat("# Initial States ", "\n", file = infile.name, append = TRUE)
    states_name <- names(initStates)
    for (i in seq_len(length(states_name))){
      states_value <- initStates[i]
      cat(paste(states_name[i], "=", states_value), ";\n", file = infile.name,
          append = TRUE, sep = "")
    }

    # Set parameter
    cat("\n# Initial parameters ", "\n", file = infile.name, append = TRUE)
    parms_name <- names(initParms)
    for (i in seq_len(length(parms_name))){
      parms_value <- initParms[i]
      cat(paste(parms_name[i], "=", parms_value), ";\n", file = infile.name,
          append = TRUE, sep = "")
    }
    cat("\n", file = infile.name, append = TRUE)

    # set outs & times
    for (i in seq_len(length(states_name))) {
      cat("Print (", paste(states_name[i], collapse = ", "), ", ",
          paste(times, collapse=", "), ");\n", file = infile.name,
          append=TRUE, sep = "")
    }

    for (i in seq_len(length(outs))) {
      cat("Print (", paste(outs[i], collapse = ", "), ", ",
          paste(times, collapse=", "), ");\n", file = infile.name,
          append=TRUE, sep = "")
    }

  } else { # Monte Carlo and sensitivity analysis

    for (i in 1 : length(condition)){
      cat(paste(condition[i], collapse = ";"), ";", "\n", file = infile.name, append = TRUE, sep = "")
    }
    cat("\n", file = infile.name, append = TRUE)
    for (i in 1 : length(vars)) {
      cat("Print (", paste(vars[i], collapse = ", "), ", ", paste(times, collapse=", "), ");\n",
          file = infile.name, append=TRUE, sep = "")
    }
  }

  cat("}", "END.\n", file = infile.name, append = TRUE)
  message(paste('* Created input file "', infile.name, '".', sep =""))
}
