# Diabetes_Care_letter
The code in this repository illustrates the methodological issues with the primary outcome used in Curovic et al. (Diabetes Care, 2023). 

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
