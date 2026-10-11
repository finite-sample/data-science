# ggplot2 in brief

A plot maps data to visual properties of geometric objects. Its main components are data, aesthetic mappings, layers, scales, coordinates, facets, and a theme. See the [ggplot2 book](https://ggplot2-book.org/) and [function reference](https://ggplot2.tidyverse.org/reference/).

The examples use datasets supplied with R and ggplot2. Run the chunks in order. The map example also requires the `maps` package.

## 1. Start with a plot

```{r setup}
library(ggplot2)
p <- ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point()
p
```

`displ` is engine displacement in liters; `hwy` is highway fuel economy in miles per gallon. `ggplot()` creates the plot specification, and `geom_point()` adds a layer. A saved plot object can be extended or printed later.

## 2. Common plots

Map a variable inside `aes()`. Set a fixed visual property outside it. Here, color distinguishes drive types, while every point has the same opacity.

```{r scatterplot}
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE)
```

The color mapping also groups the smoothers. Their shaded bands describe uncertainty about the fitted mean under the model; they are not prediction intervals for individual cars.

```{r distributions}
ggplot(mpg, aes(class, hwy)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.3)

ggplot(mpg, aes(hwy)) +
  geom_histogram(binwidth = 5, boundary = 0)

ggplot(mpg, aes(hwy)) +
  geom_density()
```

A histogram groups observations into bins. Its appearance depends on both bin width and bin boundaries. A density estimate depends on its bandwidth; its area, not its height, integrates to one.

```{r time-series}
ggplot(economics, aes(date, unemploy)) +
  geom_line() +
  labs(x = NULL, y = "Unemployed people (thousands)")
```

`geom_line()` connects points in increasing x order within each group. `geom_path()` connects them in data order.

## 3. Layers and statistics

Each layer combines data, mappings, a statistical transformation, a geometric representation, and a position adjustment. Most `geom_*()` functions choose a useful default statistic.

`geom_bar()` counts rows. `geom_col()` uses supplied heights.

```{r bars}
ggplot(mpg, aes(class)) + geom_bar()
class_counts <- as.data.frame(table(mpg$class))
names(class_counts) <- c("class", "n")
ggplot(class_counts, aes(class, n)) + geom_col()
```

For a density-scaled histogram, map the computed statistic with `after_stat()`.

```{r computed-statistics}
ggplot(mpg, aes(hwy)) +
  geom_histogram(aes(y = after_stat(density)),
                 binwidth = 5, boundary = 0, fill = "grey80") +
  geom_density()
```

## 4. Build layer by layer

A layer can use its own data or mappings. `inherit.aes = FALSE` prevents a layer from inheriting mappings that do not apply to its data.

```{r layers}
means <- aggregate(hwy ~ class, data = mpg, FUN = mean)
ggplot(mpg, aes(class, hwy)) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.2) +
  geom_point(data = means, aes(class, hwy),
             inherit.aes = FALSE, color = "red", size = 3)
```

Set `group` explicitly when observations belong to separate trajectories and no discrete aesthetic already identifies them.

```{r grouping}
ggplot(ChickWeight, aes(Time, weight, group = Chick)) +
  geom_line(alpha = 0.4) +
  labs(x = "Time (days)", y = "Weight (grams)")
```

## 5. A toolbox

Transparency, jitter, and binning can make overlapping observations easier to see. Jitter changes displayed positions, so use it deliberately.

```{r overplotting}
ggplot(diamonds, aes(carat, price)) +
  geom_bin_2d(bins = 30) +
  scale_fill_viridis_c()
```

Summaries can be calculated inside a layer. This example displays the median, not a trimmed mean.

```{r summaries}
ggplot(mpg, aes(class, hwy)) +
  stat_summary(fun = median, geom = "point", size = 3)
```

Intervals need an explicit meaning. These are 95% t intervals for group means under an independent-sampling model; the convenience sample of car models does not itself justify population inference.

```{r intervals}
mean_interval <- function(x) {
  n <- length(x)
  margin <- qt(0.975, df = n - 1) * sd(x) / sqrt(n)
  data.frame(y = mean(x), ymin = mean(x) - margin,
             ymax = mean(x) + margin)
}
ggplot(mpg, aes(class, hwy)) +
  stat_summary(fun.data = mean_interval, geom = "pointrange")
```

Annotations can use a separate layer without repeating a label for every observation.

```{r annotation}
p +
  geom_hline(yintercept = 30, linetype = "dashed") +
  annotate("text", x = 6, y = 32, label = "30 mpg reference")
```

For maps, preserve polygon grouping and choose coordinates suited to the region. This small regional example uses an approximate aspect correction at its middle latitude; it is not an equal-area projection.

```{r map}
map_data_ne <- map_data("state", region = c("vermont", "new hampshire"))
ggplot(map_data_ne, aes(long, lat, group = group)) +
  geom_polygon(fill = "grey90", color = "white", linewidth = 0.3) +
  coord_quickmap() +
  theme_void()
```

## 6. Scales, axes, and legends

Scales map data values to positions or other visual properties and supply guides such as axes and legends. Use labels to state units. A log scale requires positive values and transforms data before statistical layers are calculated.

```{r scales}
ggplot(diamonds, aes(carat, price, color = cut)) +
  geom_point(alpha = 0.2) +
  scale_x_log10() +
  scale_y_log10(labels = scales::label_dollar()) +
  scale_color_brewer(palette = "Dark2") +
  labs(x = "Carat (log scale)", y = "Price (log scale)", color = "Cut")
```

For manual colors, name the values to match the categories.

```{r manual-colors}
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  scale_color_manual(values = c("4" = "#0072B2", "f" = "#D55E00",
                                "r" = "#009E73"),
                     name = "Drive type")
```

Scale limits remove out-of-range values by default and can change computed summaries. To zoom while keeping the data used by a smoother, use coordinate limits.

```{r zoom}
p +
  geom_smooth(method = "lm", formula = y ~ x) +
  coord_cartesian(xlim = c(2, 5), ylim = c(15, 40))
```

Dates have dedicated scale arguments.

```{r dates}
ggplot(economics, aes(date, unemploy)) +
  geom_line() +
  scale_x_date(date_breaks = "10 years", date_labels = "%Y")
```

## 7. Facets and coordinates

`facet_wrap()` arranges panels for one or more variables. `facet_grid()` lays out combinations of row and column variables. Fixed scales support comparisons; free scales can reveal within-panel patterns but change that comparison.

```{r facets}
p + facet_wrap(vars(class))
p + facet_grid(rows = vars(drv), cols = vars(year))
ggplot(mpg, aes(class, fill = drv)) +
  geom_bar(position = "dodge")
```

Coordinates control how positions are drawn. Mapping the numeric variable to x is a simple way to make horizontal bars.

```{r horizontal-bars}
ggplot(class_counts, aes(n, class)) + geom_col()
```

## 8. Finish and export

Themes control non-data elements. `element_text()`, `element_line()`, `element_rect()`, and `element_blank()` specify individual components.

```{r theme}
finished <- p +
  labs(x = "Engine displacement (liters)",
       y = "Highway fuel economy (mpg)") +
  theme_bw(base_size = 12) +
  theme(panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))
finished
```

Supply the plot and dimensions when saving. Replace the temporary path with a destination of your choice.

```{r save}
output_file <- file.path(tempdir(), "fuel-economy.png")
ggsave(output_file, plot = finished, width = 7, height = 5,
       units = "in", dpi = 300)
```

Use grid viewports to arrange plots without an additional package.

```{r layout}
library(grid)
grid.newpage()
pushViewport(viewport(layout = grid.layout(1, 2)))
print(finished, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(p + facet_wrap(vars(drv)),
      vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
popViewport()
```

## 9. Prepare data

Use one row per observation and one column per variable. Compute summaries explicitly when they will be reused. Preserve polygon order when joining map data, and check whether a join duplicates rows.

```{r aggregate}
class_means <- aggregate(cbind(cty, hwy) ~ class, mpg, mean)
ggplot(class_means, aes(class, hwy)) +
  geom_point(size = 3) +
  labs(y = "Mean highway fuel economy (mpg)")
```

## 10. Reuse specifications

Keep reusable plot objects or lists of components. Add them to another plot using `+`.

```{r reuse}
quiet_axes <- list(
  scale_x_continuous(name = NULL, breaks = NULL),
  scale_y_continuous(name = NULL, breaks = NULL)
)
p + quiet_axes + theme_minimal()
```
