Array::select = (filterFunction) ->
  val for val in this when filterFunction(val)

Array::reject = (filterFunction) ->
  val for val in this when !filterFunction(val)

Array::find = (filterFunction) ->
  for val in this
    return val if filterFunction(val)

Array::compact = ->
  this.reject (val) ->
    !val?

Array::deleteAt = (index) ->
  this.splice(index, 1)

Array::inject = (memo, memoFunction) ->
  for val in this
    memo = memoFunction(memo, val)
  memo

Array::countOfValue = (val) ->
  count = 0
  for v in this
    count++ if v == val
  count

Array::max = (init=null, comparisonFunction=null) ->
  val = init ? -50000
  for v in this
    newval = if comparisonFunction? then comparisonFunction(v) else v
    if newval > val
      val = newval
  val

Array::uniq = ->
  result = []
  for v in this
    result.push(v) if $.inArray(v, result) == -1
  result
