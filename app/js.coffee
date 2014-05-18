inited = false
$(document).on( "pagebeforecreate", (event) ->
  # Just execute it one time
  if inited then return
  inited = yes
  
  # define the item class
  class MaxThermostatDeviceItem extends pimatic.DeviceItem
    constructor: (data) ->
      super(data)
      # Do something, after create: console.log(this)
    afterRender: (elements) -> 
      super(elements)
      # Do something after the html-element was added

    # define the available actions for the template
    modeAuto: -> @changeModeTo auto
    modeManu: -> @changeModeTo manu
    modeBoost: -> @changeModeTo boost
    modeEco: -> @changeTermperatureTo @config.ecoTemp
    modeComfy: -> @changeTermperatureTo @config.comfyTemp
    modeVac: -> @changeTermperatureTo @config.vacTemp
    tempPlus: -> @changeTermperatureTo @config.actTemp+0,5
    tempMinus: -> @changeTermperatureTo @config.actTemp-0,5
    setTemp: -> @changeTermperatureTo @temperature
      
  # register the item-class
  pimatic.templateClasses['MaxThermostatDevice'] = MaxThermostatDeviceItem
)