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

## ---- echo=F------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
#  mName <- "pbpk_apap"
#  pbpk_apap_model()
#  compile_model(mName, application = "mcsim")

## -----------------------------------------------------------------------------
#  params <- c("lnTg", "lnTp", "lnCYP_Km","lnCYP_VmaxC",
#             "lnSULT_Km_apap","lnSULT_Ki","lnSULT_Km_paps","lnSULT_VmaxC",
#             "lnUGT_Km","lnUGT_Ki","lnUGT_Km_GA","lnUGT_VmaxC",
#             "lnKm_AG","lnVmax_AG","lnKm_AS","lnVmax_AS",
#             "lnkGA_syn","lnkPAPS_syn", "lnCLC_APAP","lnCLC_AG","lnCLC_AS")
#  dist <- rep("Uniform", 21)
#  q <- rep("qunif", 21)
#  q.arg <-list(list(Tg-rng, Tg+rng), list(Tp-rng, Tp+rng),
#               list(CYP_Km-rng, CYP_Km+rng), list(-2., 5.),
#               list(SULT_Km_apap-rng, SULT_Km_apap+rng),
#               list(SULT_Ki-rng, SULT_Ki+rng),
#               list(SULT_Km_paps-rng, SULT_Km_paps+rng),
#               list(0, 10), list(UGT_Km-rng, UGT_Km+rng),
#               list(UGT_Ki-rng, UGT_Ki+rng),
#               list(UGT_Km_GA-rng, UGT_Km_GA+rng),
#               list(0, 10), list(Km_AG-rng, Km_AG+rng),
#               list(7., 15), list(Km_AS-rng, Km_AS+rng),
#               list(7., 15), list(0., 13), list(0., 13),
#               list(-6., 1), list(-6., 1), list(-6., 1))

## -----------------------------------------------------------------------------
#  conditions <- c("mgkg_flag = 1",
#                  "OralExp_APAP = NDoses(2, 1, 0, 0, 0.001)",
#                  "OralDose_APAP_mgkg = 20.0")
#  vars <- c("lnCPL_APAP_mcgL", "lnCPL_AG_mcgL", "lnCPL_AS_mcgL")
#  times <- seq(from = 0.1, to = 12.1, by = 0.2)

## -----------------------------------------------------------------------------
#  head(APAP)

## -----------------------------------------------------------------------------
#  set.seed(1111)
#  out <- solve_mcsim(mName = mName, params = params, vars = vars,
#                     monte_carlo = 1000, dist = dist, q.arg = q.arg,
#                     time = times, condition = conditions,
#                     rtol = 1e-7, atol = 1e-9)

## ---- fig.height=3.5, fig.width=9---------------------------------------------
#  par(mfrow = c(1,3), mar = c(4,4,1,1))
#  pksim(out, xlab = "Time (h)", ylab = "Conc. (ug/L)", main = "APAP")
#  points(APAP$Time, log(APAP$APAP * 1000))
#  pksim(out, vars = "lnCPL_AG_mcgL", xlab = "Time (h)", main = "APAP-G",
#        ylab = " ", legend = FALSE)
#  points(APAP$Time, log(APAP$AG * 1000))
#  pksim(out, vars = "lnCPL_AS_mcgL", xlab = "Time (h)", main = "APAP-S",
#        ylab = " ", legend = FALSE)
#  points(APAP$Time, log(APAP$AS * 1000))

## -----------------------------------------------------------------------------
#  set.seed(1234)
#  x <- rfast99(params = params, n = 512, q = q, q.arg = q.arg, replicate = 10)

## -----------------------------------------------------------------------------
#  out <- solve_mcsim(x, mName = mName,
#                     params = params,
#                     time = times,
#                     vars = vars,
#                     condition = conditions,
#                     rtol = 1e-7, atol = 1e-9)

## ---- fig.height=8, fig.width=8-----------------------------------------------
#  plot(out, vars = "lnCPL_APAP_mcgL")

## ---- fig.height=5------------------------------------------------------------
#  heat_check(out, order = "total order", show.all = T)

## ---- fig.height=5------------------------------------------------------------
#  heat_check(out, index = "CI", order = "total order")

