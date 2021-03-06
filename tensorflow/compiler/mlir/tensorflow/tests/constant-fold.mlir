// RUN: tf-opt %s -test-constant-fold | FileCheck %s

// CHECK-LABEL: func @testShape
func @testShape(tensor<1x32x32x16xf32>, tensor<*xf32>, tensor<f32>) -> (tensor<4xi32>, tensor<?xi32>, tensor<1xi32>) {
^bb0(%arg0: tensor<1x32x32x16xf32>, %arg1: tensor<*xf32>, %arg2: tensor<f32>):
  // Note: The resultant constant after successful constant folding is created
  // by the constant folding harness, using the original op's type as the
  // resultant constant's type. So we cannot use tensor<?xi32> as the result
  // type of tf.Shape here, otherwise the generated constant will have
  // inconsistent types internally.
  // TODO: do we need to support such different types?
  // CHECK: %cst = constant dense<[1, 32, 32, 16]> : tensor<4xi32>
  %0 = "tf.Shape"(%arg0) {T = "tfdtype$DT_FLOAT", output = "tfdtype$DT_INT32"} : (tensor<1x32x32x16xf32>) -> tensor<4xi32>
  // CHECK: %0 = "tf.Shape"(%arg1) {T = "tfdtype$DT_FLOAT", output = "tfdtype$DT_INT32"} : (tensor<*xf32>) -> tensor<?xi32>
  %1 = "tf.Shape"(%arg1) {T = "tfdtype$DT_FLOAT", output = "tfdtype$DT_INT32"} : (tensor<*xf32>) -> tensor<?xi32>
  %2 = "tf.Shape"(%arg2) {T = "tfdtype$DT_FLOAT", output = "tfdtype$DT_INT32"} : (tensor<f32>) -> tensor<1xi32>
  return %0, %1, %2 : tensor<4xi32>, tensor<?xi32>, tensor<1xi32>
}

// CHECK-LABEL: func @testLeakyRelu
func @testLeakyRelu(%arg0 : tensor<16xf32>) -> (tensor<16xf32>, tensor<f32>, tensor<f32>, tensor<16xf32>) {
  %pos = constant dense<5.0> : tensor<f32>
  %neg = constant dense<-5.0> : tensor<f32>
  %no = "tf.LeakyRelu"(%arg0) {alpha = 0.2 : f32} : (tensor<16xf32>) -> tensor<16xf32>
  %0 = "tf.LeakyRelu"(%pos) {alpha = 0.3 : f32} : (tensor<f32>) -> tensor<f32>
  %1 = "tf.LeakyRelu"(%neg) {alpha = 0.2 : f32} : (tensor<f32>) -> tensor<f32>
  %2 = "tf.LeakyRelu"(%arg0) {alpha = 3.0 : f32} : (tensor<16xf32>) -> tensor<16xf32>
  // CHECK: [[POS:%.*]] = constant dense<5.000000e+00> : tensor<f32>
  // CHECK: [[NEG:%.*]] = constant dense<-1.000000e+00> : tensor<f32>
  // CHECK: [[NC1:%.*]] = "tf.LeakyRelu"(%arg0) {alpha = 2.000000e-01 : f32} : (tensor<16xf32>) -> tensor<16xf32>
  // CHECK: [[NC2:%.*]] = "tf.LeakyRelu"(%arg0) {alpha = 3.000000e+00 : f32} : (tensor<16xf32>) -> tensor<16xf32>
  // CHECK: return [[NC1]], [[POS]], [[NEG]], [[NC2]]
  return %no, %0, %1, %2 : tensor<16xf32>, tensor<f32>, tensor<f32>, tensor<16xf32>
}

// CHECK-LABEL: func @tfConst
func @tfConst() -> (tensor<4xf32>, tensor<1x1x6x2xf32>) {
  %0 = "tf.Const"() {device = "", name = "Const", dtype = "tfdtype$DT_FLOAT", value = opaque<"tf", "0x746674656E736F722464747970653A2044545F464C4F41540A74656E736F725F7368617065207B0A202064696D207B0A2020202073697A653A20340A20207D0A7D0A74656E736F725F636F6E74656E743A20225C3030305C3030305C323430405C3030305C30303020405C3030305C303030205C3330315C3030305C3030305C3230305C323737220A"> : tensor<4xf32>} : () -> tensor<4xf32>
  %21 = "tf.Const"() {device = "", name = "Const_143", dtype = "tfdtype$DT_FLOAT", value = dense<0.24288677062973696> : tensor<1x1x6x2xf32>} : () -> tensor<1x1x6x2xf32>
  // CHECK-DAG: value = opaque<"tf"
  // CHECK-DAG: constant dense<0.242886767> : tensor<1x1x6x2xf32>
  return %0, %21 : tensor<4xf32>, tensor<1x1x6x2xf32>
}
