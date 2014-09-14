module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  _ = env.require 'lodash'
  MaxCube = require 'max-control'
 
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, @config) =>
      mc = new MaxCube(plugin.config.host, plugin.config.port)
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
          env.logger.warn "MaxThermostat could not find the mobile-frontend. No gui will be available"


  plugin = new MaxThermostat
 
  class MaxThermostatDevice extends env.devices.Device

    attributes:
      settemperature:
        description: "the temp that should be set"
        type: "number"
      mode:
        description: "the current mode"
        type: "string"
        enum: ["auto", "manu", "boost"]

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
      @getState().catch( (error) ->
        env.logger.error "error getting state: #{error.message}"
        env.logger.debug error.stack
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

    getState: () ->
      if @_state? then return Promise.resolve @_state
      mc.on "update", (data) ->
        env.logger.info "got update"
        env.logger.info data # TODO: Post data to plugin..not working now!
        return
      

    changeModeTo: (mode) ->
      if @mode is mode then return
      mc.on "connected", ->
        console.log "ready"
        setTimeout (->
          console.log "send"
          # mode: auto, manual, boost
          mc.setTemperature "DeviceID", mode, 20 #TODO: Use variables for DeviceID Post data to plugin..not working now!
          return
        ), 5000
        return
        env.logger.info "Changed mode to #{mode}"
        @_setMode(mode)
      

    changeTemperatureTo: (temperature) ->
      if @settemperature is temperature then return
      mc.on "connected", ->
        console.log "ready"
        setTimeout (->
          console.log "send"
          # mode: auto, manual, boost
          mc.setTemperature "DeviceID", @config.mode, temperature  #TODO: Use variables for DeviceID Post data to plugin..not working now!
          return
        ), 5000
        return
        @_setTemp(temperature)
        env.logger.info "Changed temperature to #{temperature} °C"
      

  return plugin
