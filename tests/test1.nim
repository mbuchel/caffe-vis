import layers
import macros

proc data_layer() {.layer_template.} =
  layer:
    name: "mnist"
    `type`: "Data"
    transform_param:
      scale: 0.00390625
    data_param:
      source: "mnist_train_lmdb"
      backend: LMDB
      batch_size: 64
    top: "data"
    top: "label"

proc conv_layer() {.layer_template.} =
  layer:
    name: "conv1"
    `type`: "Convolution"
    param:
      lr_mult: 1
    param:
      lr_mult: 2
    convolution_param:
      num_output: 20
      kernel_size: 5
      stride: 1
      weight_filler:
        `type`: "xavier"
      bias_filler:
        `type`: "constant"
    bottom: "data"
    top: "conv1"

proc pool_layer() {.layer_template.} =
  layer:
    name: "pool1"
    `type`: "Pooling"
    pooling_param:
      kernel_size: 2
      stride: 2
      pool: MAX
    bottom: "conv1"
    top: "pool1"

proc full_layer() {.layer_template.} =
  layer:
    name: "ip1"
    `type`: "InnerProduct"
    param:
      lr_mult: 1
    param:
      lr_mult: 2
    inner_product_param:
      num_output: 500
      weight_filler:
        `type`: "xavier"
      bias_filler:
        `type`: "constant"
    bottom: "pool2"
    top: "ip1"

proc relu_layer() {.layer_template.} =
  layer:
    name: "relu1"
    `type`: "ReLU"
    bottom: "ip1"
    top: "ip1"

proc prod_layer() {.layer_template.} =
  layer:
    name: "ip2"
    `type`: "InnerProduct"
    param:
      lr_mult: 1
    param:
      lr_mult: 2
    inner_product_param:
      num_output: 10
      weight_filler:
        `type`: "xavier"
      bias_filler:
        `type`: "constant"
    bottom: "ip1"
    top: "ip2"

proc loss_layer() {.layer_template.} =
  layer:
    name: "loss"
    `type`: "SoftmaxWithLoss"
    bottom: "ip2"
    bottom: "label"

const expected_data = """layer {
  name: "mnist"
  type: "Data"
  transform_param {
    scale: 0.00390625
  }
  data_param {
    source: "mnist_train_lmdb"
    backend: LMDB
    batch_size: 64
  }
  top: "data"
  top: "label"
}
"""

const expected_conv = """layer {
  name: "conv1"
  type: "Convolution"
  param {
    lr_mult: 1
  }
  param {
    lr_mult: 2
  }
  convolution_param {
    num_output: 20
    kernel_size: 5
    stride: 1
    weight_filler {
      type: "xavier"
    }
    bias_filler {
      type: "constant"
    }
  }
  bottom: "data"
  top: "conv1"
}
"""

const expected_pool = """layer {
  name: "pool1"
  type: "Pooling"
  pooling_param {
    kernel_size: 2
    stride: 2
    pool: MAX
  }
  bottom: "conv1"
  top: "pool1"
}
"""

const expected_full = """layer {
  name: "ip1"
  type: "InnerProduct"
  param {
    lr_mult: 1
  }
  param {
    lr_mult: 2
  }
  inner_product_param {
    num_output: 500
    weight_filler {
      type: "xavier"
    }
    bias_filler {
      type: "constant"
    }
  }
  bottom: "pool2"
  top: "ip1"
}
"""

const expected_relu = """layer {
  name: "relu1"
  type: "ReLU"
  bottom: "ip1"
  top: "ip1"
}
"""

const expected_prod = """layer {
  name: "ip2"
  type: "InnerProduct"
  param {
    lr_mult: 1
  }
  param {
    lr_mult: 2
  }
  inner_product_param {
    num_output: 10
    weight_filler {
      type: "xavier"
    }
    bias_filler {
      type: "constant"
    }
  }
  bottom: "ip1"
  top: "ip2"
}
"""

const expected_loss = """layer {
  name: "loss"
  type: "SoftmaxWithLoss"
  bottom: "ip2"
  bottom: "label"
}
"""

do_assert(expected_data == data_layer())
do_assert(expected_conv == conv_layer())
do_assert(expected_pool == pool_layer())
do_assert(expected_full == full_layer())
do_assert(expected_relu == relu_layer())
do_assert(expected_prod == prod_layer())
do_assert(expected_loss == loss_layer())
