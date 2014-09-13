
$(document).on( "templateinit", (event) ->
  
  # define the item class
  class MaxThermostatDeviceItem extends pimatic.DeviceItem
    
    # The value in the input
    inputValue: ko.observable()

    constructor: (templData, @device) ->
      super(templData, @device)

      modeAttr = @getAttribute('mode')
      # todo: do something with mode: maybe highlight the button
      switch modeAttr
        when 'auto'
          @manuButton.removeClass('ui-btn-active')
          @boostButton.removeClass('ui-btn-active')
          @ecoButton.removeClass('ui-btn-active')
          @comfyButton.removeClass('ui-btn-active')
          @autoButton.addClass('ui-btn-active')
        when 'manu'
          @manuButton.addClass('ui-btn-active')
          @boostButton.removeClass('ui-btn-active')
          @ecoButton.removeClass('ui-btn-active')
          @comfyButton.removeClass('ui-btn-active')
          @autoButton.removeClass('ui-btn-active')
        when 'boost'
          @manuButton.removeClass('ui-btn-active')
          @boostButton.addClass('ui-btn-active')
          @ecoButton.removeClass('ui-btn-active')
          @comfyButton.removeClass('ui-btn-active')
          @autoButton.removeClass('ui-btn-active')
          # todo: find a way to implement same behaviour for eco and comfy mode
        when 'eco'
          @manuButton.removeClass('ui-btn-active')
          @boostButton.removeClass('ui-btn-active')
          @ecoButton.addClass('ui-btn-active')
          @comfyButton.removeClass('ui-btn-active')
          @autoButton.removeClass('ui-btn-active')
        when 'comfy'
          @manuButton.removeClass('ui-btn-active')
          @boostButton.removeClass('ui-btn-active')
          @ecoButton.removeClass('ui-btn-active')
          @comfyButton.addClass('ui-btn-active')
          @autoButton.removeClass('ui-btn-active')

      # settemperature changes -> update input
      stAttr = @getAttribute('settemperature')
      stAttr.value.subscribe( (value) =>
        @inputValue(value)
      )

      # input changes -> call changeTemperatue
      @inputValue.subscribe( (textValue) =>
        if parseFloat(stAttr.value()) isnt parseFloat(textValue)
          @changeTemperatureTo(parseFloat(textValue))
      )

      # Do something, after create: console.log(this)
    afterRender: (elements) ->
      super(elements)
      # Do something after the html-element was added

    # define the available actions for the template
    modeAuto: -> @changeModeTo "auto"
    modeManu: -> @changeModeTo "manu"
    modeBoost: -> @changeModeTo "boost"
    modeEco: -> @changeTemperatureTo @config.ecoTemp
    modeComfy: -> @changeTemperatureTo @config.comfyTemp
    modeVac: -> @changeTemperatureTo @config.vacTemp
    tempPlus: -> @changeTemperatureTo @config.actTemp+0,5
    tempMinus: -> @changeTemperatureTo @config.actTemp-0,5
    setTemp: -> @changeTemperatureTo @temperature

    changeModeTo: (mode) ->
      @device.rest.changeModeTo({mode}, global: no)
        .done(ajaxShowToast)
        .fail(ajaxAlertFail)

    changeTemperatureTo: (settemperature) ->
      @device.rest.changeTemperatureTo({settemperature}, global: no)
        .done(ajaxShowToast)
        .fail(ajaxAlertFail)
      
  # register the item-class
  pimatic.templateClasses['MaxThermostatDevice'] = MaxThermostatDeviceItem
)