(function() {
  module.exports = {
    title: "max-thermostat device config schemas",
    roomID: {
      description: "The RoomID - find out with read.php",
      type: "int",
      "default": 1
    },
    deviceNo: {
      description: "The Device RF No - find out with read.php",
      type: "string",
      "default": ""
    },
    comfyTemp: {
      description: "The defined comfy temperature",
      type: "int",
      "default": 21
    },
    ecoTemp: {
      description: "The defined eco mode temperature",
      type: "int",
      "default": 17
    },
    vacTemp: {
      description: "The defined vacation mode temperature",
      type: "int",
      "default": 14
    },
    actTemp: {
      description: "The actual temperatur",
      type: "int",
      "default": 21
    },
    mode: {
      description: "The mode of the thermostat (auto/manual/boost)",
      type: "string",
      "default": "auto"
    }
  };

}).call(this);
