pimatic max thermostat plugin
=======================
Plugin to control the MAX! Thermostat (http://www.eq-3.de)


Currently not working for 0.8!
-------------


Configuration
-------------
You can load the plugin by editing your `config.json` to include:

    { 
       "plugin": "max-thermostat",
       "host": "192.168.X.X",
       "port": 62910,
       "binary": "./max.php"
    }

in the `plugins` section.

Use the "scan.php" to get your RoomID and DeviceID (use scan.php?host=CubeIP&port=62910)
Thermostats can be defined by adding them to the `devices` section in the config file.
Set the `class` attribute to `MaxThermostatDevice`. For example:

    { 
      "id": "bathroomLeft",
      "class": "MaxThermostatDevice", 
      "name": "Bathroom Radiator left",
      "roomID": 1,
      "deviceNo": "12345cf",
      "comfyTemp": 23.0,
      "ecoTemp": 17.5,
      "vacTemp": 16.5,
      "actTemp": 21.0,
      "mode": "auto"
    }
