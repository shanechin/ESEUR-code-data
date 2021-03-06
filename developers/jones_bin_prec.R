#
# jones_bin_prec.R, 21 Apr 20
# Data from:
# Developer Beliefs about Binary Operator Precedence
# Derek M. Jones
#
# Example from:
# Evidence-based Software Engineering: based on the publicly available data
# Derek M. Jones
#
# TAG experiment_human operator_precedence developer_belief operator_binary

source("ESEUR_config.r")


library("betareg")
library("plyr")


pal_col=rainbow(2)


sum_pair=function(df)
{
op_freq=src_freq[df$first_op[1], df$second_op[1]]
per_cor=length(which(df$is_correct == 1))/nrow(df)

return(data.frame(op_pair=df$op_pair[1], op_freq, per_cor, answers=nrow(df)))
}


# subj_num,first_op,second_op,prec_order,is_correct,years_exp
# prec_order: first_high=1, equal_prec=2, second_high=3
bin_prec=read.csv(paste0(ESEUR_dir, "developers/jones_bin_prec.csv.xz"), as.is=TRUE)

# Pairs sum to 96.559%...
src_pairs=read.csv(paste0(ESEUR_dir, "developers/bin_op_pairs.csv.xz"), as.is=TRUE)

colnames(src_pairs)=c("op", src_pairs$op)
rownames(src_pairs)=src_pairs$op

# The best fit (which is very poor) is the simplest
# prec_mod=glm(is_correct ~ first_op+second_op,
# 			data=bin_prec, family=binomial)
# summary(prec_mod)
#
# A better fit, but completely non-significant p-values
# prec_mod=glm(is_correct ~ op_pair,
# 			data=bin_prec, family=binomial)
# summary(prec_mod)


bin_prec$op_pair=ifelse(bin_prec$first_op < bin_prec$second_op,
			paste(bin_prec$first_op, bin_prec$second_op),
			paste(bin_prec$second_op, bin_prec$first_op))

src_freq=src_pairs
src_freq$op=NULL
dummy=sapply(src_pairs$op, function(X) src_freq[X, ] <<- src_freq[ , X])

pair_info=ddply(bin_prec, .(op_pair), sum_pair)
pair_info$l_op_freq=log(pair_info$op_freq)

pair_01=subset(pair_info, !is.na(op_freq))
# 0/1 values cannot occur
pair_01$per_cor=pair_01$per_cor*0.99999+1e-6

plot(pair_info$op_freq, pair_info$per_cor, log="x", col=pal_col[2],
	yaxs="i",
	xlab="Source code occurrence (percentage)", ylab="Correct answer (fraction)\n")

# t=loess.smooth(log(pair_info$op_freq), pair_info$per_cor, span=0.3)
# lines(exp(t$x), t$y, col=loess_col)

x_vals=seq(1e-3, 20, by=1e-3)

# p_mod=glm(per_cor ~ l_op_freq, data=pair_info)
# # p_mod=glm(per_cor ~ I(l_op_freq^2), data=pair_info)
# pred=predict(p_mod, newdata=data.frame(l_op_freq=log(x_vals)), se.fit=TRUE)
# lines(x_vals, pred$fit, col="green")
# lines(x_vals, pred$fit+1.96*pred$se.fit, col="pink")
# lines(x_vals, pred$fit-1.96*pred$se.fit, col="pink")

# betareg does not have any builtin support for confidence intervals
pb_mod=betareg(per_cor ~ l_op_freq, data=pair_01)

# Quadratic is a much better fit to the data, but the model produces
# unrealistic predictions for increasing occurrences.
# pb_mod=betareg(per_cor ~ I(l_op_freq^2), data=pair_01)

pred=predict(pb_mod, newdata=data.frame(l_op_freq=log(x_vals)))
lines(x_vals, pred, col=pal_col[1])


# library("car")
# 
# pb_boot=Boot(pb_mod)
# 
# confint is the confidence intervals of the coefficients, not the mean.
# For a two parameter family, working out the min/max is hard,
# and I could not find any suggestions about how to do it easily.
# ci_95=confint(pb_boot)
# 
