# Contextual Expectation & Pattern Separation
#### Setup #####
library(lme4)
library(reshape)
library(effects)
library(scales)
library(phia)
library(car)
library(data.table)
library(emmeans)

ds <- read.csv('CME_DataPS.csv')

ds$targ_cond = factor(ds$targ_cond)
ds$targ = factor(ds$targ,
                       levels = c('0', '1'),
                       labels = c('miss', 'hit'))
ds$f1 = factor(ds$f1,
                     levels = c('0', '1'),
                     labels = c('fa', 'cr'))
ds$f1_cond = factor(ds$f1_cond)
ds$f2 = factor(ds$f2,
                     levels = c('0', '1'),
                     labels = c('fa', 'cr'))
ds$f2_cond = factor(ds$f2_cond)
ds$f3 = factor(ds$f3,
                     levels = c('0', '1'),
                     labels = c('fa', 'cr'))
ds$f3_cond = factor(ds$f3_cond)
# rescale distances to avoid bias in model
ds$targ_ord <- rescale(abs(ds$targ_ord))
ds$f1_ord <- rescale(abs(ds$f1_ord))
ds$f2_ord <- rescale(abs(ds$f2_ord))
ds$f3_ord <- rescale(abs(ds$f3_ord))
ds$targ_f1 <- rescale(abs(ds$targ_f1))
ds$targ_f2 <- rescale(abs(ds$targ_f2))
ds$targ_f3 <- rescale(abs(ds$targ_f3))
ds$f1_f2 <- rescale(abs(ds$f1_f2))
ds$f1_f3 <- rescale(abs(ds$f1_f3))
ds$f2_f3 <- rescale(abs(ds$f2_f3))


# function to convert logit to probability
logit2prob <- function(logit){
  odds <- exp(logit)
  prob <- odds / (1 + odds)
  return(prob)
}

########### Predict firsts ###########
# first targ
targ_1st <- subset(ds,targ_pos == 1)

# f1 first
f1_1st <- subset(ds, f1_pos == 1)

#f2 first
f2_1st <- subset(ds, f2_pos == 1)

# f3 first
f3_1st <- subset(ds, f3_pos == 1)

### first foils collapsed ###
first_f1 = f1_1st[c("f1","f1_cond")]
first_f1$resp = f1_1st$f1
first_f1$resp_cond = f1_1st$f1_cond

first_f1 <- first_f1[c("resp","resp_cond")]
f2_1st$resp = f2_1st$f2
f2_1st$resp_cond = f2_1st$f2_cond
f3_1st$resp = f3_1st$f3
f3_1st$resp_cond = f3_1st$f3_cond

af1 <- nrow(f1_1st[1])
af2 <- nrow(f2_1st[1])
af3 <- nrow(f3_1st[1])
at <- nrow(targ_1st[1])

first_foils <- data.frame("subjRandID" = cbind(c(f1_1st$subjRandID,f2_1st$subjRandID,f3_1st$subjRandID)),
                          "item" = cbind(c(replicate(af1,"f1"),replicate(af2,"f2"),replicate(af3,"f3"))),
                          "resp"= cbind(c(first_f1$resp,f2_1st$resp,f3_1st$resp)),
                          "resp_cond" = cbind(c(first_f1$resp_cond,f2_1st$resp_cond,f3_1st$resp_cond)))

first_foils$resp = factor(first_foils$resp,
               levels = c('1', '2'),
               labels = c('0', '1'))


first_foils$resp_cond = factor(first_foils$resp_cond,
                          levels = c('1', '2'),
                          labels = c('expected', 'unexpected'))

first_foils_mod <- glmer(resp~item*resp_cond+(1|subjRandID), data = first_foils, family = binomial)
summary(first_foils_mod)
Anova(first_foils_mod, type = 3)
plot(allEffects(first_foils_mod))
int<-emmeans(first_foils_mod,~ item*resp_cond)
pairs(int,simple='each',adjust="FDR")

### first targets ###
first_targets <- targ_1st[c("targ","targ_cond","targ_rt")]
first_targets$resp = targ_1st$targ
first_targets$resp_cond = targ_1st$targ_cond
first_targets$rt = targ_1st$targ_rt
first_targets <- first_targets[c("resp","resp_cond","rt")]

first_targets <- data.frame("subjRandID" = cbind(targ_1st$subjRandID),
                          "item" = cbind(replicate(at,"targ")),
                          "resp"= cbind(first_targets$resp),
                          "resp_cond" = cbind(first_targets$resp_cond),
                          "rt" = cbind(first_targets$rt))

first_targets$resp = factor(first_targets$resp,
                          levels = c(1, 2),
                          labels = c('0', '1'))

first_targets$resp_cond = factor(first_targets$resp_cond,
                               levels = c('1', '2'),
                               labels = c('expected', 'unexpected'))

target_firsts <- glmer(resp~resp_cond + (1|subjRandID), data = first_targets, family = binomial)
Anova(target_firsts, type = 2)
hit_firsts <- subset(first_targets, resp == 1)

target_firsts_rt <- lmer(rt~resp_cond +(1|subjRandID), data = hit_firsts)
Anova(target_firsts_rt, type = 2)
summary(target_firsts_rt)
plot(allEffects(target_firsts_rt))


