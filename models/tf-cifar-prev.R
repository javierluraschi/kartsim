library(keras)
library(tfruns)

backend()$set_learning_phase(TRUE)
model <- keras_model_sequential()

input_layer <- layer_input(name = "input", shape = c(32, 32, 3))
previous_layer <- layer_input(name = "previous", shape = c(3))

image_layer <- input_layer %>%
  # Start with hidden 2D convolutional layer being fed 32x32 pixel images
  layer_conv_2d(
    filter = 32, kernel_size = c(3,3), padding = "same", 
    input_shape = c(32, 32, 3)
  ) %>%
  layer_activation("relu") %>%
  
  # Second hidden layer
  layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
  layer_activation("relu") %>%
  
  # Use max pooling
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  layer_dropout(0.25) %>%
  
  # 2 additional hidden 2D convolutional layers
  layer_conv_2d(filter = 32, kernel_size = c(3,3), padding = "same") %>%
  layer_activation("relu") %>%
  layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
  layer_activation("relu") %>%
  
  # Use max pooling once more
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  
  # Flatten max filtered output into feature vector 
  layer_flatten() %>%
  layer_dropout(0.2)
  
# Inject last known direction as a feature
predictions_output <- layer_concatenate(
    c(
      image_layer,
      previous_layer
    )
  ) %>%
  
  # and feed into dense layer
  layer_dense(512) %>%
  layer_activation("relu") %>%
  layer_dropout(0.2) %>%
  
  layer_dense(64) %>%
  layer_activation("relu") %>%
  layer_dropout(0.2) %>%
  
  # Outputs from dense layer are projected onto 10 unit output layer
  layer_dense(3) %>%
  layer_activation("softmax")

# Link inputs to predictions
model <- keras_model(
  inputs = c(input_layer, previous_layer),
  outputs = predictions_output
)

opt <- optimizer_rmsprop(lr = 0.0001, decay = 1e-6)

model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = opt,
  metrics = "accuracy"
)

library(png)
classes <- c("left", "forward", "right")

batch_size <- 32

image_generator <- function(path, batch_size) {
  image_files <- dir(path, full.names = T)
  total_files <- length(image_files)
  function() {
    start <- floor(runif(1, 1, max(1, total_files - batch_size)))
    
    images <- c()
    labels <- c()
    previous <- c()
    actual_previous <- NULL
    
    for (i in start:(min(total_files, start + batch_size - 1))) {
      image_file <- image_files[[i]]
      image_label <- gsub(".*-|\\.[a-z]+", "", image_file)
      images <- c(images, array(png::readPNG(image_file), c(1L, 32L, 32L, 3L)))
      
      label <- rep(0, 3)
      label[which(labels == "forward")] <- 1
      labels <- c(labels, label)
      
      if (is.null(actual_previous))
        previous <- c(previous, array(rep(0,3), c(3)))
      else
        previous <- c(previous, actual_previous)
      
      actual_previous <- label
    }
    
    images_tensor <- array(images, c(batch_size, 32L, 32L, 3L))
    previous_tensor <- array(labels, c(batch_size, 3L))
    labels_tensor <- array(labels, c(batch_size, 3L))
    
    list(list(input = images_tensor, previous = previous_tensor), labels_tensor)
  }
}

model %>% fit_generator(
  generator = image_generator("capture", batch_size),
  steps_per_epoch = length(dir("capture")) / batch_size, 
  epochs = 500
)

model %>% export_savedmodel("savedmodel")
