#
# sample-distrib.R, 29 Sep 18
#
# Data from:
#
# Example from:
# Evidence-based Software Engineering: based on the publicly available data
# Derek M. Jones
#
# TAG example


source("ESEUR_config.r")


library("VGAM")


plot_layout(3, 2, max_width=6, max_height=11.0)
par(mar=c(1.0, 1.0, 1, 0.5))

pal_col=rainbow(2)

NUM_REPLICATE=4000


plot_sample=function(sample_size, samp_mean, dist_mean, dist_str)
{
samp_den=density(samp_mean)
actual_sd=dist_mean/sqrt(sample_size)
x_bounds=c(dist_mean-4*actual_sd, dist_mean+4*actual_sd)

xpoints=seq(0, max(x_bounds), by=0.01)
norm_sd=dist_mean/sqrt(sample_size)
ypoints=dnorm(xpoints, mean=dist_mean, sd=norm_sd)
y_bounds=range(c(samp_den$y, ypoints))

# Density of sample passed in
plot(samp_den, col=pal_col[1], fg="grey", col.axis="grey", yaxt="n",
	bty="n", yaxt="n",
	main="",
	xlab="", ylab="",
	xlim=x_bounds, ylim=y_bounds)

# 95% of values occur between pair of lines
q=quantile(samp_mean, c(0.025, 0.975))
lines(c(q[1], q[1]), c(0, max(y_bounds)/3), col=pal_col[1])
lines(c(q[2], q[2]), c(0, max(y_bounds)/3), col=pal_col[1])

# The normal distribution towards which an infinite number of samples converges
lines(xpoints, ypoints, col=pal_col[2], fg="grey")

q=c(dist_mean-norm_sd*1.96, dist_mean+norm_sd*1.96)
lines(c(q[1], q[1]), c(0, max(y_bounds)/3), col=pal_col[2])
lines(c(q[2], q[2]), c(0, max(y_bounds)/3), col=pal_col[2])

# Line showing where the mean values are
# rep_mean=mean(samp_mean)
# lines(c(dist_mean, dist_mean), c(0, max(y_bounds)), col=pal_col[2])
# lines(c(rep_mean, rep_mean), c(0, max(y_bounds)), col=pal_col[1])

legend(x="topright", legend=c(paste0("size=", sample_size)), title=dist_str,
				bty="n", cex=1.3)
}



exp_samp_dis=function(sample_size)
{
samp_mean=replicate(NUM_REPLICATE, mean(rexp(sample_size)))

dist_mean=1
plot_sample(sample_size, samp_mean, dist_mean, "Exponential")
}



lnorm_samp_dis=function(sample_size)
{
samp_mean=replicate(NUM_REPLICATE, mean(rlnorm(sample_size)))

dist_mean=exp(0.5)
plot_sample(sample_size, samp_mean, dist_mean, "Lognormal")
}



pareto_samp_dis=function(sample_size)
{
p_shape=2
samp_mean=replicate(NUM_REPLICATE, mean(rpareto(sample_size, scale=1, shape=p_shape)))

dist_mean=1*p_shape/(p_shape-1)

plot_sample(sample_size, samp_mean, dist_mean, "Pareto")
}


exp_samp_dis(10)
lnorm_samp_dis(10)
pareto_samp_dis(20)

exp_samp_dis(20)
lnorm_samp_dis(20)
pareto_samp_dis(200)


