module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  _ = env.require 'lodash'
  MaxCube = require 'max-control'
  
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, @config) =>
      @mc = new MaxCube(plugin.config.host, plugin.config.port)
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
      @getState()
      
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

    hasOwnProperty = Object::hasOwnProperty
    isEmpty = (obj) ->
      return true  unless obj?
      return false  if obj.length and obj.length > 0
      return true  if obj.length is 0
      for key of obj
        return false  if hasOwnProperty.call(obj, key)
      true

    getState: () ->
      if @_state? then return Promise.resolve @_state
      plugin.mc.on "update", (data) =>
        if !isEmpty(data)
          @config.actTemp = data[@config.deviceNo].setpoint
          @config.mode = data[@config.deviceNo].mode
          @config.comfyTemp = data[@config.deviceNo].comfortTemperature
          @config.ecoTemp = data[@config.deviceNo].ecoTemperature
          @config.battery = data[@config.deviceNo].battery
          env.logger.info "got update"
          env.logger.info data
        return

      

    changeModeTo: (mode) ->
      if @mode is mode then return
      plugin.mc.on "connected", ->
        console.log "ready"
        setTimeout (->
          console.log "send"
          # mode: auto, manual, boost
          plugin.mc.setTemperature "#{@config.deviceNo}", mode, 20 #TODO: Post data to plugin..not working now!
          return
        ), 5000
        return
        env.logger.info "Changed mode to #{mode}"
        @_setMode(mode)
      

    changeTemperatureTo: (temperature) ->
      if @settemperature is temperature then return
      plugin.mc.on "connected", ->
        console.log "ready"
        setTimeout (->
          console.log "send"
          # mode: auto, manual, boost
          plugin.mc.setTemperature "#{@config.deviceNo}", "#{@config.mode}", temperature  #TODO: Post data to plugin..not working now!
          return
        ), 5000
        return
        @_setTemp(temperature)
        env.logger.info "Changed temperature to #{temperature} °C"
      

  return plugin
