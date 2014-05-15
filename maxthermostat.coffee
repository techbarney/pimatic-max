module.exports = (env) ->
  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'
  _ = env.require 'lodash'

  exec = Q.denodeify(require("child_process").exec)
 
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, config) =>
      conf = convict require("./maxthermostat-config-schema")
      conf.load config
      conf.validate()
      @config = conf.get ""
      @checkBinary()

      # wait till all plugins are loaded
      @framework.on "after init", =>
        # Check if the mobile-frontent was loaded and get a instance
        mobileFrontend = @framework.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-max-thermostat/app/js.coffee"
          # mobileFrontend.registerAssetFile 'css', "pimatic-max-thermostat/app/css/css.css"
          mobileFrontend.registerAssetFile 'html', "pimatic-max-thermostat/app/html.jade"
      else
          env.logger.warn "MaxThermostat could not find the mobile-frontend. No gui will be available"



    checkBinary: ->
      exec("#{@config.binary} -v").catch( (error) ->
        if error.message.match "not found"
          env.logger.error "max.php binary not found. Check your config!"
      ).done()
 
    createDevice: (deviceConfig) =>
      switch deviceConfig.class
        when "MaxThermostatDevice" 
          @framework.registerDevice(new MaxThermostatDevice deviceConfig)
          return true
        else
          return false

  plugin = new MaxThermostat
 
  class MaxThermostatDevice extends env.devices.Device
 

    constructor: (config) ->
      conf = convict _.cloneDeep(require("./device-config-schema"))
      conf.load config
      conf.validate()
      @config = conf.get ""

      @name = config.name
      @id = config.id
      super()

    # define the available actions for the template 
    modeAuto: -> @changeModeTo auto
    modeManu: -> @changeModeTo manu
    modeBoost: -> @changeModeTo boost
    modeEco: -> @changeTermperatureTo @config.ecoTemp
    modeComfy: -> @changeTermperatureTo @config.comfyTemp
    modeVac: -> @changeTermperatureTo @config.vacTemp
    tempPlus: -> @changeTermperatureTo @config.actTemp+0,5
    tempMinus: -> @changeTermperatureTo @config.actTemp-0,5
    setTemp: -> @changeTermperatureTo @temperature


    getState: () ->
      if @_state? then return Q @_state
      # Built the command to get the thermostat status
      command = "php #{plugin.config.binary}" # define the binary
      command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += "status" # get status of the thermostat
      # and execue it. TODO: Still need to parse the JSON data!!
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        stdout = stdout.trim()
        for (var i=0; i<stdout.length; i++)
          for (var name in stdout[i]) {
        config.actTemp = stdout[i][actTemp];
        config.mode = stdout[i][mode];
        config.comfyTemp = stdout[i][comfyTemp];
        config.ecoTemp = stdout[i][ecoTemp];
        }
        # Build error handling here..

    changeModeTo: (mode) ->
      if @mode is mode then return
      # Built the command
      command = "php #{plugin.config.binary}" # define the binary
      command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += "mode #{@mode}" # set mode of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.debug stderr if stderr.length isnt 0
        @_setMode(mode)

    changeTermperatureTo: (temperature) ->
      if @temperature is temperature then return
      # Built the command
      command = "php #{plugin.config.binary}" # define the binary
      command += "#{plugin.config.host} #{plugin.config.port}" # select the host and port of the cube
      command += "#{@config.RoomID} #{@config.deviceNo}" # select the RoomID and deviceNo
      command += "temp #{@temperature}" # set temperature of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.debug stderr if stderr.length isnt 0
        @_setMode(mode)
      )
    getTemplateName: -> "MaxThermostatDevice"

  return MaxThermostat