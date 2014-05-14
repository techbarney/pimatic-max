pimatic max thermostat plugin
=======================
Plugin to control the MAX! Thermostat (http://www.eq-3.de)


Configuration
-------------
You can load the plugin by editing your `config.json` to include:

    { 
       "plugin": "max-thermostat",
       "host": "192.168.X.X",
       "port": 62910,
       "cmdPath": "/path/to/send.php"
    }

in the `plugins` section.

Use the "read.php" to get your RoomID and DeviceID (identify by the name)
Thermostats can be defined by adding them to the `devices` section in the config file.
Set the `class` attribute to `MaxThermostatDevice`. For example:

    { 
      "id": "bathroomLeft",
      "class": "MaxThermostatDevice", 
      "name": "Bathroom Radiator left",
      "deviceNo": "12345cf",
  		"comfyTemp": 23.0,
		"ecoTemp": 17.5,
		"vacTemp": 16.5,
		"actTemp": 21.0,
		"mode": "auto"
    }