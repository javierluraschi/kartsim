hexkart: Kart simulation for model training
================

Getting Started
---------------

Clone this GitHub repo and open the package project in RStudio, then launch this simulation running as a `htmlwidget` as follows:

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

Once the session is captured, we can train a TensorFlow model by using:

``` r
tfruns::training_run("models/tensorflow.R")
```

or in `cloudml` runnning:

``` r
cloudml::cloudml_train("models/tensorflow.R")
```

use `tfdeploy` to validate that predictions over the trained model work by running:

``` r
tfdeploy::predict_savedmodel(array(0, c(32,32,3)))
```

    ## $predictions
    ##                   output
    ## 1 0.3329, 0.3310, 0.3361
