kartsim: Kart simulation for model training
================

`kartsim` provides a kart simulation to render and capture kart training data using 'HTML' widgets or 'Shiny' applications. It can be used to: Collect kart playing styles, create test cases for image classification and render trained models over an interactive kart simulation.

Getting Started
---------------

Install `kartsim` from CRAN then launch the imulation as follows, use arrow keys to turn left or right:

``` r
library(kartsim)
kartsim_play()
```

![](tools/README/kart-demo.gif)

To capture a kart session simply run:

``` r
kartsim_capture()
```

This will create a snapshot under `capture/` with labels: `###-left.png`, `###-forward.png` or `###-right.png` that you can use for training. Once trained, you can use `kartsim_control()` to feed predictions back.

We can feed a random direction to this simulation by running:

``` r
labels <- c("left", "forward", "right")
kartsim::kartsim_control(function(image, direction) {
  sample(labels, 1)
})
```

Training
--------

Training this simulation is beyond the scope of this package, but the following github repos can be used for further reading. Feel free to send a PR to this repo if you want your models to be listed here:

-   [github.com/javierluraschi/kartmodels](http://github.com/javierluraschi/kartmodels)
