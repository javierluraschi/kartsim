hexkart: Kart simulation for model training
================

Getting Started
---------------

Build the package then launch this `htmlwidget` as follows:

``` r
library(hexkart)
hexkart_play()
```

![](tools/README/kart-demo.gif)

To capture a kart session simply run:

``` r
hexkart_capture()
```

This will create a snapshot under `capture/` with labels: `left-###.png`, `right-###.png` or `forward-###.png`.
