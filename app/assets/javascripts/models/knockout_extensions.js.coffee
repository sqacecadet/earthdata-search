do (ko, $=jQuery) ->

  ko.observableArray.fn.contains = (obj) ->
    @indexOf(obj) != -1

  ko.observableArray.fn.isEmpty = (obj) ->
    this().length == 0

  # Valid names: 'added', 'deleted', 'retained'
  ko.observableArray.fn.subscribeChange = (status, callback) ->
    previousValue = null

    beforeChange = (oldValue) ->
      previousValue = oldValue.slice(0)

    afterChange = (latestValue) ->
      for {status, value} in ko.utils.compareArrays(previousValue, latestValue)
        callback?(value) if status == 'name'
      previousValue = null

    @subscribe(beforeChange, undefined, 'beforeChange')
    @subscribe(afterChange)

  ko.observableArray.fn.subscribeAdd = (callback) ->
    @subscribeChange('added', callback)

  ko.observableArray.fn.subscribeRemove = (callback) ->
    @subscribeChange('deleted', callback)

  # For observables that need to make an XHR or similar call to compute their value
  ko.asyncComputed = (initialValue, timeout, method, obj) ->
    value = ko.observable(initialValue)

    callAsyncMethod = ->
      method.call obj, value.peek(), (newValue) ->
        value(newValue)

    asyncComputed = ko.computed
      read: ->
        val = value.peek()
        callAsyncMethod()
        val
      write: value
      deferEvaluation: true

    isSetup = false

    ko.computed
      read: ->
        # Causes an evaluation of computed, thereby setting up dependencies correctly
        asyncComputed.extend(throttle: timeout) unless isSetup
        isSetup = true
        value()
      write: (newValue) ->
        isSetup = true
        value(newValue)
      deferEvaluation: true


  ko.bindingHandlers.showModal =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->

    update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      isShown = ko.unwrap(valueAccessor())
      if isShown
        method = 'show'
      else
        method = 'hide'
      $(element).modal(method)