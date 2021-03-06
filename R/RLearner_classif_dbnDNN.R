#' @export
makeRLearner.classif.dbnDNN = function() {
  makeRLearnerClassif(
    cl = "classif.dbnDNN",
    package = "deepnet",
    par.set = makeParamSet(
      makeIntegerVectorLearnerParam(id = "hidden", default = 10, lower = 1),
      makeDiscreteLearnerParam(id = "activationfun", default = "sigm", values = c("sigm", "linear", "tanh")),
      makeNumericLearnerParam(id = "learningrate", default = 0.8, lower = 0),
      makeNumericLearnerParam(id = "momentum", default = 0.5, lower = 0),
      makeNumericLearnerParam(id = "learningrate_scale", default = 1, lower = 0),
      makeIntegerLearnerParam(id = "numepochs", default = 3, lower = 1),
      makeIntegerLearnerParam(id = "batchsize", default = 100, lower = 1),
      makeDiscreteLearnerParam(id = "output", default = "sigm", values = c("sigm", "linear", "softmax")),
      makeNumericLearnerParam(id = "hidden_dropout", default = 0, lower = 0, upper = 1),
      makeNumericLearnerParam(id = "visible_dropout", default = 0, lower = 0, upper = 1),
      makeIntegerLearnerParam(id = "cd")
    ),
    par.vals = list(output = "softmax"),
    properties = c("twoclass", "multiclass", "numerics", "prob"),
    name = "Deep neural network with weights initialized by DBN",
    short.name = "dbn.dnn",
    note = '`output` set to `"softmax"` by default.',
    callees = "dbn.dnn.train"
  )
}

#' @export
trainLearner.classif.dbnDNN = function(.learner, .task, .subset, .weights = NULL,  ...) {
  d = getTaskData(.task, .subset, target.extra = TRUE)
  y = as.numeric(d$target)
  dict = sort(unique(y))
  onehot = matrix(0, length(y), length(dict))
  for (i in seq_along(dict)) {
    ind = which(y == dict[i])
    onehot[ind, i] = 1
  }
  deepnet::dbn.dnn.train(x = data.matrix(d$data), y = onehot, ...)
}

#' @export
predictLearner.classif.dbnDNN = function(.learner, .model, .newdata, ...) {
  type = switch(.learner$predict.type, response = "class", prob = "raw")
  pred = deepnet::nn.predict(.model$learner.model, data.matrix(.newdata))
  colnames(pred) = .model$factor.levels[[1]]

  if (type == "class") {
    classes = colnames(pred)[max.col(pred)]
    return(as.factor(classes))
  }
  return(pred)
}
