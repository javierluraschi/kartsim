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

prepare_flow_images <- function(source_path) {
  output_path <- tempfile()
  dir.create(output_path)
  for (path in dir(source_path, full.names = T)) {
    for (d in c("left", "forward", "right")) {
      if (grepl(d, path)) {
        if (!file.exists(file.path(output_path, d))) dir.create(file.path(output_path, d))
        file.copy(path, file.path(output_path, d, basename(path)))
      }
    }
  }
  output_path
}

train_path <- prepare_flow_images("capture/train")
test_path <- prepare_flow_images("capture/test")

model %>% fit_generator(
  flow_images_from_directory(
    train_path,
    classes = classes,
    batch_size = batch_size,
    target_size = c(32, 32)),
  steps_per_epoch = as.integer(length(dir("capture/train")) / batch_size), 
  epochs = 5,
  validation_data = flow_images_from_directory(
    test_path,
    classes = classes,
    batch_size = batch_size,
    target_size = c(32, 32))
)

model %>% export_savedmodel("savedmodel")
