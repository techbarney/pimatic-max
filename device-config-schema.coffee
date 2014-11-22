module.exports = {
  title: "max-thermostat device config schemas"
  MaxThermostatDevice: {
    title: "MaxThermostatDevice config options"
    type: "object"
    properties:
      rfAddress:
        description: "The Device RF address"
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
      rfAddress:
        description: "The Device RF address"
        type: "string"
        default: ""
  }
  MaxCube: {
    title: "MaxCube config options"
    type: "object"
    properties: {}
  }
}