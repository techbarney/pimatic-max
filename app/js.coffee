
$(document).on( "templateinit", (event) ->
  
  # define the item class
  class MaxThermostatDeviceItem extends pimatic.DeviceItem
    
    # The value in the input
    inputValue: ko.observable()

    constructor: (data) ->
      super(data)

      modeAttr = @getAttribute('mode')
      console.log modeAttr

      stAttr = @getAttribute('settemperature')
      console.log stAttr
      stAttr.value.subscribe( (value) =>
        @inputValue(value)
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
      $.get("/api/device/#{@deviceId}/changeModeTo/#{mode}").fail(ajaxAlertFail)

    changeTermperatureTo: (temp) ->
      $.get("/api/device/#{@deviceId}/changeTermperatureTo/#{temp}").fail(ajaxAlertFail)
      
  # register the item-class
  pimatic.templateClasses['MaxThermostatDevice'] = MaxThermostatDeviceItem
)