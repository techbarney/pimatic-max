
$(document).on( "templateinit", (event) ->
  
  # define the item class
  class MaxThermostatDeviceItem extends pimatic.DeviceItem
    
    # The value in the input
    inputValue: ko.observable()

    constructor: (data) ->
      super(data)

      modeAttr = @getAttribute('mode')
      # todo: do something with mode: maybe highlight the button

      # settemperature changes -> update input
      stAttr = @getAttribute('settemperature')
      stAttr.value.subscribe( (value) =>
        @inputValue(value)
      )

      # input changes -> call changeTemperatue
      @inputValue.subscribe( (textValue) =>
        if parseFloat(stAttr.value()) isnt parseFloat(textValue)
          @changeTermperatureTo(parseFloat(textValue))
      )

      # Do something, after create: console.log(this)
    afterRender: (elements) -> 
      super(elements)
      # Do something after the html-element was added

    # define the available actions for the template
    modeAuto: -> @changeModeTo "auto"
    modeManu: -> @changeModeTo "manu"
    modeBoost: -> @changeModeTo "boost"
    modeEco: -> @changeTermperatureTo @config.ecoTemp
    modeComfy: -> @changeTermperatureTo @config.comfyTemp
    modeVac: -> @changeTermperatureTo @config.vacTemp
    tempPlus: -> @changeTermperatureTo @config.actTemp+0,5
    tempMinus: -> @changeTermperatureTo @config.actTemp-0,5
    setTemp: -> @changeTermperatureTo @temperature

    changeModeTo: (mode) ->
      $.ajax(
        url: "/api/device/#{@deviceId}/changeModeTo"
        data: {mode}
      ).fail(ajaxAlertFail)

    changeTermperatureTo: (settemperature) ->
      $.ajax(
        url:"/api/device/#{@deviceId}/changeTermperatureTo"        
        data: {settemperature}
      ).fail(ajaxAlertFail)
      
  # register the item-class
  pimatic.templateClasses['MaxThermostatDevice'] = MaxThermostatDeviceItem
)