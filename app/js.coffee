
$(document).on( "templateinit", (event) ->
  
  # define the item class
  class MaxThermostatDeviceItem extends pimatic.DeviceItem
    
    # The value in the input
    inputValue: ko.observable()

    constructor: (templData, @device) ->
      super(templData, @device)

      # settemperature changes -> update input
      stAttr = @getAttribute('settemperature')
      @inputValue(stAttr.value())
      stAttr.value.subscribe( (value) =>
        @inputValue(value)
      )

      # input changes -> call changeTemperature
      @inputValue.subscribe( (textValue) =>
        if parseFloat(stAttr.value()) isnt parseFloat(textValue)
          @changeTemperatureTo(parseFloat(textValue))
      )

      # Do something, after create: console.log(this)
    afterRender: (elements) ->
      super(elements)
      # find the buttons
      #@elementAttr = @elements
      @autoButton = $(elements).find('[name=autoButton]')
      @manuButton = $(elements).find('[name=manuButton]')
      @boostButton = $(elements).find('[name=boostButton]')
      @ecoButton = $(elements).find('[name=ecoButton]')
      @comfyButton = $(elements).find('[name=comfyButton]')
      @vacButton = $(elements).find('[name=vacButton]')
      console.log "Auto Button:"
      console.log @autoButton
      @updateButtons()
      @getAttribute('mode').value.subscribe( =>
        @updateButtons()
      )
      return

    # define the available actions for the template
    modeAuto: -> @changeModeTo "auto"
    modeManu: -> @changeModeTo "manu"
    modeBoost: -> @changeModeTo "boost"
    modeEco: -> @changeTemperatureTo "#{@device.config.ecoTemp}"
    modeComfy: -> @changeTemperatureTo "#{@device.config.comfyTemp}"
    modeVac: -> @changeTemperatureTo "#{@device.config.vacTemp}"
    tempPlus: -> @changeTemperatureTo "#{@device.config.actTemp+0.5}"
    tempMinus: -> @changeTemperatureTo "#{@device.config.actTemp-0.5}"
    setTemp: -> @changeTemperatureTo @temperature # TODO: put real temp in here!

    updateButtons: ->
      modeAttr = @getAttribute('mode').value()
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
      return

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