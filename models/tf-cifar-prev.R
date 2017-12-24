library(keras)
library(tfruns)

backend()$set_learning_phase(TRUE)
model <- keras_model_sequential()

model %>%
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
  layer_dropout(0.25) %>%
  
  # Inject last known direction as a feature
  # state_input <- tf$Input(shape=state_input_shape)
  
  # Flatten max filtered output into feature vector 
  # and feed into dense layer
  layer_flatten() %>%
  layer_dense(512) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5)

model %>%
  # Outputs from dense layer are projected onto 10 unit output layer
  layer_dense(3) %>%
  layer_activation("softmax")

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
    
    for (i in start:(min(total_files, start + batch_size - 1))) {
      image_file <- image_files[[i]]
      image_label <- gsub(".*-|\\.[a-z]+", "", image_file)
      images <- c(images, array(png::readPNG(image_file), c(1L, 32L, 32L, 3L)))
      
      label <- rep(0, 3)
      label[which(labels == "forward")] <- 1
      labels <- c(labels, label)
    }
    
    images_tensor <- array(images, c(batch_size, 32L, 32L, 3L))
    labels_tensor <- array(labels, c(batch_size, 3L))
    
    list(images_tensor, labels_tensor)
  }
}

model %>% fit_generator(
  generator = image_generator("capture", batch_size),
  steps_per_epoch = 2, 
  epochs = 5
)

model %>% export_savedmodel("savedmodel")
