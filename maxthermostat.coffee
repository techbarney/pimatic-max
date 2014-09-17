module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  _ = env.require 'lodash'
  MaxCube = require 'max-control'
  
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, @config) =>

      # Promise that is resolved when the connection is established
      @afterConnect = new Promise( (resolve, reject) =>
        @mc = new MaxCube(plugin.config.host, plugin.config.port)
        @mc.once("connected", resolve)
        @mc.client.once('error', reject)
        return
      ).timeout(60000).catch( (error) =>
        env.logger.error "Error on connecting to max cube: #{error.message}"
        env.logger.debug error.stack
        return
      )

      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("MaxThermostatDevice", {
        configDef: deviceConfigDef.MaxThermostatDevice,
        createCallback: (config) -> new MaxThermostatDevice(config)
      })

      # wait till all plugins are loaded
      @framework.on "after init", =>
        # Check if the mobile-frontent was loaded and get a instance
        mobileFrontend = @framework.pluginManager.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-max-thermostat/app/js.coffee"
          # mobileFrontend.registerAssetFile 'css', "pimatic-max-thermostat/app/css/css.css"
          mobileFrontend.registerAssetFile 'html', "pimatic-max-thermostat/app/template.html"
        else
          env.logger.warn(
            "MaxThermostat could not find the mobile-frontend. No gui will be available"
          )


  plugin = new MaxThermostat
 
  class MaxThermostatDevice extends env.devices.Device

    attributes:
      settemperature:
        description: "the temp that should be set"
        type: "number"
      mode:
        description: "the current mode"
        type: "string"
        enum: ["auto", "manual", "boost"]

    actions:
      changeModeTo:
        params: 
          mode: 
            type: "string"
      changeTemperatureTo:
        params: 
          settemperature: 
            type: "number"

    template: "MaxThermostatDevice"

    _mode: "auto"
    _settemperature: null

    constructor: (@config) ->
      @id = @config.id
      @name = @config.name
      @_settemperature = @config.actTemp

      plugin.mc.on("update", (data) =>
        data = data[@config.deviceNo]
        if data?
          @config.actTemp = data.setpoint
          @config.mode = data.mode
          @config.comfyTemp = data.comfortTemperature
          @config.ecoTemp = data.ecoTemperature
          @config.battery = data.battery
          env.logger.debug "got update"
          env.logger.debug data
        return
      )
      super()

    getMode: () -> Promise.resolve(@_mode)
    getSettemperature: () -> Promise.resolve(@_settemperature)

    _setMode: (mode) ->
      if mode is @_mode then return
      @_mode = mode
      @emit "mode", @_mode

    _setTemp: (settemperature) ->
      if settemperature is @_settemperature then return
      @_settemperature = settemperature
      @emit "settemperature", @_settemperature

    changeModeTo: (mode) ->
      return plugin.afterConnect.then( =>
        # mode: auto, manual, boost
        plugin.mc.setTemperature @config.deviceNo, mode, 20 
        @_setMode(mode)
        return mode
      )

    changeTemperatureTo: (temperature) ->
      if @settemperature is temperature then return
      return plugin.afterConnect.then( =>
        plugin.mc.setTemperature @config.deviceNo, @config.mode, temperature  
        @_setTemp(temperature)
        return temperature
      )

  return plugin
