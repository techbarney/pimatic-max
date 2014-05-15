module.exports = (env) ->
 
  class MaxThermostat extends env.plugins.Plugin
 
    init: (app, @framework, config) =>
      conf = convict require("./maxthermostat-config-schema")
      conf.load config
      conf.validate()
      @config = conf.get ""
      @checkBinary()


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

  getState: () ->
      if @_state? then return Q @_state
      # Built the command to get the thermostat status
      command = "php #{plugin.config.binary}?" # define the binary
      command += "host=#{plugin.config.host}&port=#{plugin.config.port}" # select the host and port of the cube
      command += "&RoomID=#{@config.RoomID}&deviceNo=#{@config.deviceNo}" # select the RoomID and deviceNo
      command += "&type=status" # get status of the thermostat
      # and execue it. TODO: Still need to parse the JSON data!!
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        stdout = stdout.trim()
        switch stdout
          when "1"
            @_state = on
            return Q @_state
          when "0"
            @_state = off
            return Q @_state
          else 
            env.logger.debug stderr
            throw new Error "MaxThermostat: unknown state=\"#{stdout}\"!"
        )

  changeModeTo: (mode) ->
      if @mode is mode then return
      # Built the command
      command = "php #{plugin.config.binary}?" # define the binary
      command += "host=#{plugin.config.host}&port=#{plugin.config.port}" # select the host and port of the cube
      command += "&RoomID=#{@config.RoomID}&deviceNo=#{@config.deviceNo}" # select the RoomID and deviceNo
      command += "&mode=#{@mode}" # set mode of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.debug stderr if stderr.length isnt 0
        @_setMode(mode)

  changeTermperatureTo: (temperature) ->
      if @temperature is temperature then return
      # Built the command
      command = "php #{plugin.config.binary}?" # define the binary
      command += "host=#{plugin.config.host}&port=#{plugin.config.port}" # select the host and port of the cube
      command += "&RoomID=#{@config.RoomID}&deviceNo=#{@config.deviceNo}" # select the RoomID and deviceNo
      command += "&temp=#{@temperature}" # set temperature of the thermostat
      # and execue it.
      return exec(command).then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.debug stderr if stderr.length isnt 0
        @_setMode(mode)
      )
 

  return MaxThermostat