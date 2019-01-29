## ----setup, include = FALSE----------------------------------------------
library(pksensi)
#mcsim_install(mxstep = 5000)
#library(kableExtra)
knitr::opts_chunk$set(
  collapse = TRUE,
  fig.height=5, 
  fig.width=8,
  comment = "#>"
)

## ---- echo=F, eval=F-----------------------------------------------------
#  #Nominal value
#  Tg <- log(0.23)
#  Tp <- log(0.033)
#  CYP_Km <- log(130)
#  SULT_Km_apap <- log(300)
#  SULT_Ki <- log(526)
#  SULT_Km_paps <- log(0.5)
#  UGT_Km <- log(6.0e3)
#  UGT_Ki <- log(5.8e4)
#  UGT_Km_GA <-log(0.5)
#  Km_AG <- log(1.99e4)
#  Km_AS <- log(2.29e4)
#  
#  r <- 1.96 # exp(1.96)/exp(-1.96) ~ 50
#  
#  x <- c("Tg", "Tp", "CYP_Km", "CYP_VmaxC",
#         "SULT_Km_apap","SULT_Ki","SULT_Km_paps","SULT_VmaxC",
#         "UGT_Km","UGT_Ki","UGT_Km_GA","UGT_VmaxC",
#         "Km_AG","Vmax_AG","Km_AS","Vmax_AS",
#         "kGA_syn","PAPS_syn", "CLC_APAP","CLC_AG","CLC_AS")
#  y <- c("Gatric emptying time constant",
#         "GI perfusion time constant",
#         "Cytochrome P450 metabolism, Km",
#         "Cytochrome P450 metabolism, VMax",
#         "Sulfation pathway acetaminophen, Km",
#         "Sulfation pathway substrate inhibition, Ki",
#         "Sulfation pathway PAPS, Km",
#         "Sulfation pathway acetaminophen, Vmax",
#         "Glucronidation pathway acetaminophen, Km",
#         "Glucronidation pathway substrate inhibition, Ki",
#         "Glucronidation pathway GA, Km",
#         "Glucronidation pathway acetaminophen, Vmax",
#         "APAP-G hepatic transporter, Km",
#         "APAP-G hepatic transporter, Vmax",
#         "APAP-S hepatic transporter, Km",
#         "APAP-S hepatic transporter, Vmax",
#         "UDPGA synthesis",
#         "PAPS synthesis",
#         "APAP clearance",
#         "APAP-G clearance",
#         "APAP-S clearance")
#  z <- c("$h$", "$h$", "$\\mu{M}$", "$\\mu{mole}/h\\cdot{BW}^{0.75}$",
#         "$\\mu{M}$", "$\\mu{M}$", "$-$", "$\\mu{mole}/h\\cdot{BW}^{0.75}$",
#         "$\\mu{M}$", "$\\mu{M}$", "$-$", "$\\mu{mole}/h\\cdot{BW}^{0.75}$",
#         "$\\mu{M}$", "$\\mu{mole}/h$", "$\\mu{M}$", "$\\mu{mole}/h$",
#         "$1/h$", "$1/h$",
#         "$L/h\\cdot{BW}^{0.75}$", "$L/h\\cdot{BW}^{0.75}$", "$L/h\\cdot{BW}^{0.75}$")
#  min <- c(round(Tg-r, 3), round(Tp-r, 3), round(CYP_Km-r), round(log(0.14), 3),
#           round(SULT_Km_apap-r, 3), round(SULT_Ki-r, 3), round(SULT_Km_paps-r), log(1),
#           round(UGT_Km-r, 3), round(UGT_Ki-r, 3), round(UGT_Km_GA-r), log(1),
#           round(Km_AG-r, 3), round(log(1.09e3), 3), round(Km_AS-r), round(log(1.09e3), 3),
#           log(1), log(1), round(log(2.48e-3), 3), round(log(2.48e-3), 3), round(log(2.48e-3), 3))
#  max <- c(round(Tg+r, 3), round(Tp+r, 3), round(CYP_Km+r), round(log(2900), 3),
#           round(SULT_Km_apap+r, 3), round(SULT_Ki+r, 3), round(SULT_Km_paps+r), round(log(22026), 3),
#           round(UGT_Km+r, 3), round(UGT_Ki+r, 3), round(UGT_Km_GA+r), round(log(22026), 3),
#           round(Km_AG+r, 3), round(log(3.26e6), 3), round(Km_AS+r), round(log(3.26e6), 3),
#           round(log(4.43e5), 3), round(log(4.43e5),3),
#           round(log(2.718), 3), round(log(2.718), 3), round(log(2.718), 3))
#  
#  df <- data.frame(x, y, z, min, max)
#  names(df) <- c("Parameter","Description", "Unit", "Min", "Max")
#  
#  #if (require(kableExtra)) {
#    knitr::kable(df, format = 'html', align=c("l","l","l", "c", "c"),
#                 caption = "Table 1 Description of sampling range of model parameter")
#    #%>% kableExtra::add_footnote(c("The parameter valur are showed in log-transformed scale."), notation = "number")
#  #}
#  

## ---- eval=F-------------------------------------------------------------
#  # Nominal value
#  Tg <- log(0.23)
#  Tp <- log(0.033)
#  CYP_Km <- log(130)
#  SULT_Km_apap <- log(300)
#  SULT_Ki <- log(526)
#  SULT_Km_paps <- log(0.5)
#  UGT_Km <- log(6.0e3)
#  UGT_Ki <- log(5.8e4)
#  UGT_Km_GA <-log(0.5)
#  Km_AG <- log(1.99e4)
#  Km_AS <- log(2.29e4)
#  
#  rng <- 1.96

## ---- eval=F-------------------------------------------------------------
#  params <- c("lnTg", "lnTp", "lnCYP_Km","lnCYP_VmaxC",
#             "lnSULT_Km_apap","lnSULT_Ki","lnSULT_Km_paps","lnSULT_VmaxC",
#             "lnUGT_Km","lnUGT_Ki","lnUGT_Km_GA","lnUGT_VmaxC",
#             "lnKm_AG","lnVmax_AG","lnKm_AS","lnVmax_AS",
#             "lnkGA_syn","lnkPAPS_syn", "lnCLC_APAP","lnCLC_AG","lnCLC_AS")
#  q <- "qunif"
#  q.arg <-list(list(Tg-rng, Tg+rng),
#               list(Tp-rng, Tp+rng),
#               list(CYP_Km-rng, CYP_Km+rng),
#               list(-2., 5.),
#               list(SULT_Km_apap-rng, SULT_Km_apap+rng),
#               list(SULT_Ki-rng, SULT_Ki+rng),
#               list(SULT_Km_paps-rng, SULT_Km_paps+rng),
#               list(0, 10),
#               list(UGT_Km-rng, UGT_Km+rng),
#               list(UGT_Ki-rng, UGT_Ki+rng),
#               list(UGT_Km_GA-rng, UGT_Km_GA+rng),
#               list(0, 10),
#               list(Km_AG-rng, Km_AG+rng),
#               list(7., 15),
#               list(Km_AS-rng, Km_AS+rng),
#               list(7., 15),
#               list(0., 13),
#               list(0., 13),
#               list(-6., 1),
#               list(-6., 1),
#               list(-6., 1))
#  
#  times <- seq(from = 0.1, to = 12.1, by = 0.2)
#  set.seed(1234)
#  x <- rfast99(params = params, n = 512, q = q, q.arg = q.arg, replicate = 10)

## ---- eval=F-------------------------------------------------------------
#  mName <- "pbpk_apap"
#  pbpk_apap_model()
#  compile_model(mName, application = "mcsim")

## ---- eval=F-------------------------------------------------------------
#  vars <- c("lnCPL_APAP_mcgL", "lnCPL_AG_mcgL", "lnCPL_AS_mcgL")
#  conditions <- c("mgkg_flag = 1",
#                  "OralExp_APAP = NDoses(2, 1, 0, 0, 0.001)",
#                  "OralDose_APAP_mgkg = 20.0")
#  generate_infile(params = params,
#                  vars = vars,
#                  time = times,
#                  condition = conditions,
#                  rtol = 1e-7, atol = 1e-9)
#  system.time(y <- solve_mcsim(x, mName = mName,
#                               params = params,
#                               vars = vars,
#                               time = times,
#                               condition = conditions,
#                               generate.infile = F))
#  tell2(x,y)

## ---- eval=F, fig.height=8, fig.width=8, fig.cap = 'Figure 1. '----------
#  plot(x, vars = "lnCPL_AG_mcgL")

## ---- eval=F, fig.cap = 'Figure 2. The range of model simulation based on parameter distribution'----
#  par(mfrow = c(2,2), mar = c(2,2,1,1), oma = c(2,2,1,1))
#  pksim(y, vars = "lnCPL_APAP_mcgL")
#  text(1, 15, "APAP",cex = 1.2)
#  points(APAP$Time, log(APAP$APAP * 1000))
#  pksim(y, vars = "lnCPL_AG_mcgL", legend = F)
#  text(1, 15, "AG",cex = 1.2)
#  points(APAP$Time, log(APAP$AG * 1000))
#  pksim(y, vars = "lnCPL_AS_mcgL", legend = F)
#  text(1, 15, "AS",cex = 1.2)
#  points(APAP$Time, log(APAP$AS * 1000))
#  mtext("Time", SOUTH<-1, line=0.4, cex=1.2, outer=TRUE)
#  mtext("Conc.", WEST<-2, line=0.4, cex=1.2, outer=TRUE)

## ---- eval=F-------------------------------------------------------------
#  check(x)

## ---- eval=F-------------------------------------------------------------
#  check(x, vars = "lnCPL_APAP_mcgL", SI.cutoff = 0.1, CI.cutoff = 0.1)

## ---- eval=F, 'Figure 3: Heatmap of sensitivity index for interaction'----
#  heat_check(x, order = "interaction")

## ---- eval=F, 'Figure 4: Heatmap of convergence index for total order'----
#  heat_check(x, order = "total order")

## ---- eval=F, fig.height=9, 'Figure 5: Heatmap of convergence index'-----
#  heat_check(x, index = "CI", CI.cutoff = 0.05)

