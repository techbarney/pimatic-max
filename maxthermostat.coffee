module.exports = (env) ->
  convict = env.require "convict"
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  _ = env.require 'lodash'
  
  

  exec = Promise.promisify(require("child_process").exec)
 
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, config) =>
      @checkBinary()

      @isDemo = config.demo

      deviceConfigDef = require("./device-config-schema")

      @framework.registerDeviceClass("MaxThermostatDevice", {
      configDef: deviceConfigDef.MaxThermostatDevice, 
      createCallback: (deviceConfig) => new MaxThermostatDevice(deviceConfig)
      })

      # wait till all plugins are loaded
      @framework.on "after init", =>
        # Check if the mobile-frontent was loaded and get a instance
        mobileFrontend = @framework.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-max-thermostat/app/js.coffee"
          # mobileFrontend.registerAssetFile 'css', "pimatic-max-thermostat/app/css/css.css"
          mobileFrontend.registerAssetFile 'html', "pimatic-max-thermostat/app/template.html"
        else
          env.logger.warn "MaxThermostat could not find the mobile-frontend. No gui will be available"



      checkBinary: ->
        command = "php #{plugin.config.binary}" # define the binary
        command += " #{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
        command += " #{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
        command += "check" # see if max.php is there
        exec(command).catch( (error) ->
          if error.message.match "not found"
            env.logger.error "max.php binary not found. Check your config!"
          else
            env.logger.info "Found max.php"
        ).done()

  plugin = new MaxThermostat
 
  class MaxThermostatDevice extends env.devices.Device

    _mode: "auto"
    _settemperature: null
 
    constructor: (@config) ->
      @id = deviceconfig.id
      @name = deviceconfig.name
      @getState()
      super()

    getMode: () -> Promise.resolve (@_mode)
    getSettemperature: () -> Promise.resolve (@_settemperature)

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
      # Built the command to get the thermostat status
      command = "php #{plugin.config.binary}" # define the binary
      command += " #{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += " #{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += " status" # get status of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        stdout = stdout.trim()
        data = JSON.parse stdout
        config.actTemp = data.actTemp
        config.mode = data.mode
        config.comfyTemp = data.comfyTemp
        config.ecoTemp = data.ecoTemp
        env.logger.info command
        @_setMode(data.mode)
        @_setTemp(data.actTemp)
        plugin.framework.saveConfig()
      )


    changeModeTo: (mode) ->
      if @mode is mode then return
      # Built the command
      command = "php #{plugin.config.binary}" # define the binary
      command += " #{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += " #{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += " mode x #{mode}" # set mode of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.debug stderr if stderr.length isnt 0
        env.logger.info "Changed mode to #{mode}"
        @_setMode(mode)
       )

    changeTemperatureTo: (temperature) ->
      if @settemperature is temperature then return
      # Built the command
      command = "php #{plugin.config.binary}" # define the binary
      command += " #{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += " #{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += " temp #{temperature}" # set temperature of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.debug stderr if stderr.length isnt 0
        env.logger.info command
        env.logger.info "Changed temperature to #{temperature} °C"
        @_setTemp(temperature)
      )
    getTemplateName: -> "MaxThermostatDevice"

  return plugin
