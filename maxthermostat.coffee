module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  _ = env.require 'lodash'
  MaxCube = require 'max-control'
  M = env.matcher
  
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, @config) =>

      @framework.ruleManager.addActionProvider(new MaxModeActionProvider(@framework))

      # Promise that is resolved when the connection is established
      @afterConnect = new Promise( (resolve, reject) =>
        env.logger.debug "Remember to fill config with dummy values to get debug output!"
        @mc = new MaxCube(plugin.config.host, plugin.config.port)
        @mc.once("connected", resolve)
        @mc.client.once('error', reject)
        return
      ).timeout(60000).catch( (error) ->
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
          mobileFrontend.registerAssetFile 'css', "pimatic-max-thermostat/app/css/css.css"
          mobileFrontend.registerAssetFile 'html', "pimatic-max-thermostat/app/template.html"
        else
          env.logger.warn "MaxThermostat could not find the mobile-frontend. No gui will be available"


  plugin = new MaxThermostat
 
  class MaxThermostatDevice extends env.devices.Device

    attributes:
      settemperature:
        description: "the temp that should be set"
        type: "number"
        unit: "°C"
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
      @_settemperature = @config.actTemp

      plugin.mc.on("update", (data) =>
        env.logger.debug "got update"
        env.logger.debug data
        data = data[@config.deviceNo]
        if data?
            @config.actTemp = data.setpoint
            @config.mode = data.mode
            @config.comfyTemp = data.comfortTemperature
            @config.ecoTemp = data.ecoTemperature
            @config.battery = data.battery
            @_setTemp(@config.actTemp)
            @_setMode(@config.mode)
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
        plugin.mc.setTemperature @config.deviceNo, mode, @config.actTemp 
        @_setMode(mode)
        return mode
      )

    changeTemperatureTo: (temperature) ->
      if @settemperature is temperature then return
      return plugin.afterConnect.then( =>
        env.logger.debug "temp is going to change"
        plugin.mc.setTemperature @config.deviceNo, @config.mode, temperature  
        @_setTemp(temperature)
        return temperature
      )
       

  class MaxModeActionProvider extends env.actions.ActionProvider

    constructor: (@framework) -> 
    # ### executeAction()
    ###
    This function handles action in the form of `set mode to "some mode"`
    ###
    parseAction: (input, context) =>
      retVal = null
      modeTokens = null
      fullMatch = no

      setMode = (m, tokens) => modeTokens = tokens
      onEnd = => fullMatch = yes
      
      m = M(input, context)
        .match("set mode to ")
        .matchStringWithVars(setMode)
      
      if m.hadMatch()
        match = m.getFullMatch()
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new MaxModeActionHandler(@framework, modeTokens)
        }
      else
        return null


  class MaxModeActionHandler extends env.actions.ActionHandler

    constructor: (@framework, @modeTokens, @config) ->
    # ### executeAction()
    ###
    This function handles action in the form of `set mode to "some mode"`
    ###
    executeAction: (simulate) =>
      @framework.variableManager.evaluateStringExpression(@modeTokens).then( (command) =>
        if simulate
          # just return a promise fulfilled with a description about what we would do.
          return __("would set mode to \"%s\"", command)
        else
          return __("TODO: define actual action: ", command)
      )

  class MaxTempActionProvider extends env.actions.ActionProvider

    constructor: (@framework) -> 
    # ### executeAction()
    ###
    This function handles action in the form of `set temp to "some temp"`
    ###
    parseAction: (input, context) =>
      retVal = null
      tempTokens = null
      fullMatch = no

      setTemp = (m_, tokens) => tempTokens = tokens
      onEnd = => fullMatch = yes
      
      m_ = M(input, context)
        .match("set temp to ")
        .matchStringWithVars(setMode)
      
      if m.hadMatch()
        match = m.getFullMatch()
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new MaxTempActionHandler(@framework, tempTokens)
        }
      else
        return null


  class MaxTempActionHandler extends env.actions.ActionHandler

    constructor: (@framework, @tempTokens, @config) ->
    # ### executeAction()
    ###
    This function handles action in the form of `set temp to "some temp"`
    ###
    executeAction: (simulate) =>
      @framework.variableManager.evaluateStringExpression(@tempTokens).then( (command) =>
        if simulate
          # just return a promise fulfilled with a description about what we would do.
          return __("would set temp to \"%s\"", command)
        else
          return __("TODO: define actual action:", command)
      )
  return plugin
