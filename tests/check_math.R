close <- function(x, y, tolerance = 1e-8) {
  stopifnot(isTRUE(all.equal(as.numeric(x), as.numeric(y), tolerance = tolerance)))
}

# OLS risk, likelihood criteria, and classification denominators.
x <- c(-3, -1, 0, 2, 5, 8); y <- c(-4, 1, 0, 5, 8, 17)
fit <- lm(y ~ x)
close(1 - deviance(fit) / deviance(lm(y ~ 1)), summary(fit)$r.squared)
k <- attr(logLik(fit), "df")
close(-2 * logLik(fit) + 2 * k, AIC(fit))
close(-2 * logLik(fit) + log(length(y)) * k, BIC(fit))
predictions <- c(1, 2, 4, 5); noise <- c(-2, 2)
close(mean(outer(predictions, noise, function(p, e) (3 + e - p)^2)),
      (3 - mean(predictions))^2 + mean((predictions - mean(predictions))^2) + mean(noise^2))
tp <- 5; fn <- 7; tn <- 78; fp <- 10
close(tn / (tn + fp) + fp / (tn + fp), 1)
close(1 - (tp / (tp + fn) + tn / (tn + fp)) / 2,
      (fn / (tp + fn) + fp / (tn + fp)) / 2)

# Pairwise and centroid definitions of k-means dispersion agree.
points <- rbind(cbind(c(-3,-2,-1), c(0,1,-1)), cbind(c(3,4,5), c(4,6,5)))
clusters <- c(1,1,1,2,2,2)
means <- rowsum(points, clusters) / as.vector(table(clusters))
within <- sum((points - means[clusters, ])^2)
pairwise <- sum(vapply(split(seq_len(nrow(points)), clusters), function(i) {
  sum(as.matrix(dist(points[i, ]))^2) / (2 * length(i))
}, numeric(1)))
close(within, pairwise)
km <- kmeans(points, centers = means, algorithm = "Lloyd")
close(within, km$tot.withinss)
between <- sum(as.vector(table(clusters)) * rowSums(sweep(means, 2, colMeans(points))^2))
close(between, km$betweenss)
close(between + within, sum(scale(points, scale = FALSE)^2))
ch <- (between / (nrow(means) - 1)) / (within / (nrow(points) - nrow(means)))
stopifnot(is.finite(ch), ch > 0)
start <- points[c(1,4), ]
stopifnot(within <= sum((points - start[clusters, ])^2))
distances <- sapply(seq_len(nrow(means)), function(j) rowSums(sweep(points, 2, means[j, ])^2))
stopifnot(sum(apply(distances, 1, min)) <= within)

# Check the gap statistic and its one-standard-error rule against cluster.
set.seed(24)
gap <- cluster::clusGap(points, FUNcluster = kmeans, K.max = 3, B = 20,
                       d.power = 2, verbose = FALSE)
close(gap$Tab[, "gap"], gap$Tab[, "E.logW"] - gap$Tab[, "logW"])
g <- c(.4, .6, .63, .64); se <- rep(.05, 4)
rule <- which(g[-length(g)] >= g[-1] - se[-1])[1]
close(rule, cluster::maxSE(g, se, method = "Tibs2001SEmax"))

# BH step-up rejection sets, including ties and no discoveries.
for (p in list(c(.001,.01,.01,.04,.2), c(.2,.5,.8), c(.01,.03,.1))) {
  q <- .05; ordered <- sort(p); eligible <- which(ordered <= seq_along(p) * q / length(p))
  rejected <- if (length(eligible)) p <= ordered[max(eligible)] else rep(FALSE, length(p))
  stopifnot(identical(rejected, p.adjust(p, method = "BH") <= q))
}
close(adist("intention", "execution"), 5)
close(adist("intention", "execution", costs = c(insertions=1, deletions=1, substitutions=2)), 8)
close(20e9 * 20e3, 400e12)
close(400e12 / 50e6 / 1000 / 3600, 2.2222222222)
close(10e12 * 8 / 1e9 / 3600, 22.2222222222)

# Execute the actual plotting chunks; build and draw each returned plot.
script <- tempfile(fileext = ".R")
invisible(knitr::purl("graphs/ggplot2.md", output = script, documentation = 0, quiet = TRUE))
plot_env <- new.env(parent = globalenv())
graphics_file <- tempfile(fileext = ".pdf")
pdf(graphics_file)
count <- 0
withCallingHandlers({
  for (expression in parse(script)) {
    evaluated <- withVisible(eval(expression, envir = plot_env))
    result <- evaluated$value
    if (evaluated$visible && inherits(result, "ggplot")) {
      ggplot2::ggplotGrob(result)
      print(result)
      count <- count + 1
    }
  }
}, warning = function(w) stop(conditionMessage(w), call. = FALSE))
dev.off()
stopifnot(count >= 20, file.info(plot_env$output_file)$size > 0,
          file.info(graphics_file)$size > 0)
close(plot_env$mean_interval(1:5)$y, 3)
close(plot_env$mean_interval(1:5)$ymax, t.test(1:5)$conf.int[2])
unlink(c(script, graphics_file, plot_env$output_file))
cat("Mathematical checks and", count, "rendered plotting examples passed.\n")
