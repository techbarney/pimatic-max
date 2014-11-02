module.exports = {
  title: "max-thermostat device config schemas"
  MaxThermostatDevice: {
    title: "MaxThermostatDevice config options"
    type: "object"
    properties:
      roomID:
        description: "The RoomID - find out with read.php"
        type: "integer"
        default: 1
      deviceNo:
        description: "The Device RF No - find out with read.php"
        type: "string"
        default: ""
      comfyTemp:
        description: "The defined comfy temperature"
        type: "number"
        default: 21
      ecoTemp:
        description: "The defined eco mode temperature"
        type: "number"
        default: 17
      vacTemp:
        description: "The defined vacation mode temperature"
        type: "number"
        default: 14
      actTemp: 
        description: "The actual temperatur"
        type: "number"
        default: 21
      mode: 
        description: "The mode of the thermostat (auto/manu/boost)"
        type: "string"
        default: "auto" 
      battery: 
        description: "The battery status"
        type: "string"
        default: "ok"
      guiShowModeControl: 
        description: "Show the mode buttons in the gui"
        type: "boolean"
        default: true
      guiShowPresetControl:
        description: "Show the preset temperatures in the gui"
        type: "boolean"
        default: true
      guiShowTemperatueInput:
        description: "Show the temperature input spinbox in the gui"
        type: "boolean"
        default: true        
  }
  MaxContactSensor: {
    title: "MaxContactSensor config options"
    type: "object"
    properties:
      deviceNo:
        description: "The Device RF adress"
        type: "string"
        default: ""
  }
  MaxCube: {
    title: "MaxCube config options"
    type: "object"
    properties: {}
  }
}