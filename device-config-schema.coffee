# #MaxThermostat Device configuration options

# Defines a `node-convict` config-schema and exports it.

module.exports =
  deviceNo:
    doc: "The Device RF No - find out with read.php"
    format: "String"
    default: ""
  comfyTemp:
    doc: "The defined comfy temperature"
    format: "int"
    default: 21.0
  ecoTemp:
    doc: "The defined eco mode temperature"
    format: "int"
    default: 16.5
  vacTemp:
    doc: "The defined vacation mode temperature"
    format: "int"
    default: 14.5
  actTemp: 
    doc: "The actual temperatur"
    format: "int"
    default: 21.0
  mode: 
    doc: "The mode of the thermostat (auto/manual/boost)"
    format: "String"
    default: "auto"