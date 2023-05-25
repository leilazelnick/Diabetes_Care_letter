
###############################################################
###############################################################
###############################################################
#
# Simulation code to accompany "Comment on 'Optimization of Albuminuria-Lowering Treatment in Diabetes by Crossover Rotation to Four Different Drug Classes: A Randomized Crossover Trial' by Curovic et al. (2023)" (https://pubmed.ncbi.nlm.nih.gov/36657986/)
#
# Author: Leila Zelnick, PhD, University of Washington
# Email: lzelnick@uw.edu
#
# The following code runs a simulation illustrating the methodological
# issues with the design of the trial implemented in Curovic et al.
# (Diabetes Care, 2023). Specifically, the issue stems from the
# selective inference induced by comparing the "winner" drug class
# for an individual with the mean response of the three "loser"
# classes, where the mean response of the "losers" is estimated
# from the same periods that defined them as "losers".
#
# Under the global null hypothesis of no response to any class of drug,
# this design rejects the null hypothesis of no difference between
# response to the "winner" (y5) and mean response to the "losers"
# 67% of the time, instead of the putative Type I error rate of 5%.
#
# I also demonstrate that adding confirmatory periods for the "losers"
# (y6-y8) and using these for comparison -- that is, decoupling the
# process of selection of the "losers" and estimation of the difference
# -- solves the issue and returns the Type I error rate to near 5%.
#
# The secondary analysis comparing the correlation of the "winner"'s
# response in the initial period and confirmatory period has an
# appropriate Type I error rate of 5%.
#
###############################################################
###############################################################
###############################################################

library(tidyverse)

N <- 63

do.one <- function(N, alpha=0.05){

  # Simulate responses to drug classes in each period
  # y1-y4: initial four crossover periods
  y1 <- rnorm(N, mean=0, sd=0.75) # Use the SD used in Curovic et al. power calculations
  y2 <- rnorm(N, mean=0, sd=0.75)
  y3 <- rnorm(N, mean=0, sd=0.75)
  y4 <- rnorm(N, mean=0, sd=0.75)
  # y5: confirmatory period for the "winner"
  y5 <- rnorm(N, mean=0, sd=0.75)
  # y6-y8: confirmatory periods for the three "losers"
  y6 <- rnorm(N, mean=0, sd=0.75)
  y7 <- rnorm(N, mean=0, sd=0.75)
  y8 <- rnorm(N, mean=0, sd=0.75)

  dat <- tibble(y1, y2, y3, y4, y5, y6, y7, y8) %>%
    rowwise() %>%
    mutate(winner_response = max(y1, y2, y3, y4),
           loser_mean_response = (y1 + y2 + y3 + y4 - winner_response)/3,
           loser_confirmatory_mean_response = (y6 + y7 + y8)/3)

  # Primary analysis compares the "winner"'s confirmatory value with the
  # mean response of the "losers" from the initial period which
  # identified them as the "losers"
  pval_primary <- t.test(dat$y5, dat$loser_mean_response, paired=T)$p.value
  # We'll also look at the distribution of test statistics from this test
  t_primary <- t.test(dat$y5, dat$loser_mean_response, paired=T)$statistic

  # Proposed analytic alternative: these issues can be fixed by comparing
  # responses between "winner" and "losers", all estimated from the
  # confirmatory periods (y5-y8)
  pval_proposed <- t.test(dat$y5, dat$loser_confirmatory_mean_response, paired=T)$p.value
  # Look at the distribution of the test statistic from the proposed analysis
  t_proposed <- t.test(dat$y5, dat$loser_confirmatory_mean_response, paired=T)$statistic

  # Also look at Type 1 error rate for the secondary outcome
  pval_cor <- cor.test(dat$winner_response, dat$y5)$p.value

  return(c(reject_primary = pval_primary < alpha,
           reject_proposed = pval_proposed < alpha,
           reject_cor = pval_cor < alpha,
           t_primary = t_primary,
           t_proposed = t_proposed))
}

set.seed(29)
B <- 5000
res <- replicate(B, do.one(N=63)) # This takes a few minutes to run
save(res, file="curovic_2023_diabetes_care_sim.Rdata")
res <- get(load("curovic_2023_diabetes_care_sim.Rdata"))

# Actual Type I error rate for the primary outcome as analyzed in Curovic et al. is 67% -- far exceeding the nominal Type I error rate of 5%
mean(res["reject_primary",]) # 0.6708
# Actual Type I error rate for the proposed outcome is 4% -- much closer to the nominal Type I error rate of 5%
mean(res["reject_proposed",]) # 0.0438
# Actual Type I error rate for the correlation analysis is 5%
mean(res["reject_cor",]) # 0.0506

# Look at the distribution of the test statistics under the null
# For a correctly sized test, the distribution of the "winner" minus the mean response of the "losers" (all ascertained from confirmatory periods) is normally distributed about zero
hist(res["t_proposed.t",], xlab="Test statistic", main="Test statistic for corrected analysis")
# We reject the null hypothesis when the test statistic falls outside of the dotted red lines, which occurs 4% of the time under the null
abline(v = qt(0.975, df=62), col="red", lty=2, lwd=2)
abline(v = qt(0.025, df=62), col="red", lty=2, lwd=2)
# For the incorrectly sized primary analysis, the distribution of the "winner" minus the mean response of the "losers" (where this mean response comes from periods that identified them as "losers") is *NOT* normally distributed and not centered at zero.
hist(res["t_primary.t",], xlab="Test statistic", main="Test statistic for Curovic et al. primary analysis")
# We reject the null hypothesis when the test statistic falls outside of the dotted red lines, which occurs 67% of the time, not 5% of the time, under the null
abline(v = qt(0.975, df=62), col="red", lty=2, lwd=2)
abline(v = qt(0.025, df=62), col="red", lty=2, lwd=2)


