pimatic max thermostat plugin
=======================

Plugin to control the MAX! Thermostat (http://www.eq-3.de)

Configuration
-------------
You can load the plugin by editing your `config.json` to include (host = Max!Cube IP port=Max!Cube Port (default:62910)):

````json
{ 
   "plugin": "max-thermostat",
   "host": "192.168.X.X",
   "port": 62910
}
````

Use the debug output in pimatic to find out the rfAddress of the devices. Sample debug output:

````
09:04:42.165 [pimatic-max-thermostat] got update
09:04:42.168 [pimatic-max-thermostat] { type: 'Heating Thermostat',
09:04:42.168 [pimatic-max-thermostat]>  address: '12345cf', <-- rfAddress
09:04:42.168 [pimatic-max-thermostat]>  serial: 'KEQ04116',
09:04:42.168 [pimatic-max-thermostat]>  name: 'Heizung',
09:04:42.168 [pimatic-max-thermostat]>  roomId: 1,
09:04:42.168 [pimatic-max-thermostat]>  comfortTemperature: 23,
09:04:42.168 [pimatic-max-thermostat]>  ecoTemperature: 16.5,
09:04:42.168 [pimatic-max-thermostat]>  maxTemperature: 30.5,
09:04:42.168 [pimatic-max-thermostat]>  minTemperature: 4.5,
09:04:42.168 [pimatic-max-thermostat]>  temperatureOffset: 3.5,
09:04:42.168 [pimatic-max-thermostat]>  windowOpenTemperature: 12,
09:04:42.168 [pimatic-max-thermostat]>  valve: 0,
09:04:42.168 [pimatic-max-thermostat]>  setpoint: 17,
09:04:42.168 [pimatic-max-thermostat]>  battery: 'ok',
09:04:42.168 [pimatic-max-thermostat]>  mode: 'manu' }
````
  
Thermostats can be defined by adding them to the `devices` section in the config file.
Set the `class` attribute to `MaxThermostatDevice`. For example:

```json
{ 
  "id": "bathroomLeft",
  "class": "MaxThermostatDevice", 
  "name": "Bathroom Radiator left",
  "rfAddress": "12345cf",
  "comfyTemp": 23.0,
  "ecoTemp": 17.5,
}
```

For contact sensors add this config:

```json
{ 
  "id": "window-bathroom",
  "class": "MaxContactSensor", 
  "name": "Bathroom Window",
  "rfAddress": "12345df"
}
```
