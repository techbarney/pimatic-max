pimatic max thermostat plugin
=======================
Plugin to control the MAX! Thermostat (http://www.eq-3.de)



Installation
-------------
1. 
Clone this repository into your pimatic node_modules folder (eg. /home/pi/pimatic/node_modules)

2. 
You can load the plugin by editing your `config.json` to include (host = Max!Cube IP port=Max!Cube Port (default:62910)):

    ````
    { 
       "plugin": "max-thermostat",
       "host": "192.168.X.X",
       "port": 62910
    }
    ````

in the `plugins` section. Also you will need to create a dummy device (explained further down) to get the debug output! This step is important!

3.
Also you'll need to install the connector software "max-control" written by https://github.com/aslansky
In the install dir (eg. ../node_modules/pimatic-max-thermostat) do a `sudo npm install`


Configuration
-------------
Use the debug output in pimatic to find out your roomID & available devices. Currently we only have support for thermostats!

Sample debug output:

  ````
  09:04:42.165 [pimatic-max-thermostat] got update
  09:04:42.168 [pimatic-max-thermostat] { type: 'Heating Thermostat',
  09:04:42.168 [pimatic-max-thermostat]>  address: '12345cf', <-- deviceID
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
      "mode": "auto",
      "battery": ""
    }

For contactSensors add this config:


    { 
      "id": "window-bathroom",
      "class": "MaxContactSensor", 
      "name": "Bathroom Window",
      "deviceNo": "12345df"
    }

Screenshot
-------------
[![Screenshot 1][screen1_thumb]](https://cloud.githubusercontent.com/assets/6489464/4346733/d30e7710-4110-11e4-87a7-934770234a84.PNG) 
[screen1_thumb]: https://cloud.githubusercontent.com/assets/6489464/4346733/d30e7710-4110-11e4-87a7-934770234a84.PNG
