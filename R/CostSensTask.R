#' @export
#' @rdname Task
#' @family costsens
makeCostSensTask = function(id = deparse(substitute(data)), data, costs, blocking = NULL, fixup.data = "warn", check.data = TRUE) {
  assertString(id)
  assertDataFrame(data)
  assertChoice(fixup.data, choices = c("no", "quiet", "warn"))
  assertFlag(check.data)

  # we don't have a target nor weights
  target = character(0L)
  weights = NULL

  if (fixup.data != "no") {
    assert(checkMatrix(costs), checkDataFrame(costs))
    if (is.data.frame(costs))
      costs = as.matrix(costs)
    if (is.null(colnames(costs)))
      colnames(costs) = stri_paste("y", seq_col(costs))
  }
  task = makeSupervisedTask("costsens", data, target, weights, blocking, fixup.data = fixup.data, check.data = check.data)

  if (check.data) {
    assertMatrix(costs, any.missing = FALSE, col.names = "strict")
    assertNumeric(costs, lower = 0)
    if (nrow(costs) != nrow(data))
      stopf("Number of rows in cost matrix (%s) should equal the number of observations (%s).", nrow(costs), nrow(data))
    # we use ..y.. later in the models as a name for temp labels
    if ("..y.." %in% c(colnames(data), colnames(costs)))
      stopf("The name '..y..' is currently reserved for costsens tasks. You can use it neither for features nor labels!")
  }

  task$task.desc = makeCostSensTaskDesc(id, data, target, blocking, costs)
  addClasses(task, "CostSensTask")
}

makeCostSensTaskDesc = function(id, data, target, blocking, costs) {
  td = makeTaskDescInternal("costsens", id, data, target, weights = NULL, blocking = blocking)
  td$class.levels = colnames(costs)
  td$costs = costs
  return(addClasses(td, c("CostSensTaskDesc", "SupervisedTaskDesc")))
}

#' @export
print.CostSensTask = function(x, ...) {
  print.SupervisedTask(x, print.target = FALSE, print.weights = FALSE)
  levs = x$task.desc$class.levels
  catf("Classes: %i\n%s", length(levs), clipString(collapse(levs, sep = ", "), 30L))
}
