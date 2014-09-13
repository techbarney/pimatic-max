(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = function(env) {
    var MaxThermostat, MaxThermostatDevice, Promise, assert, convict, exec, plugin, _, _ref;
    convict = env.require("convict");
    Promise = env.require('bluebird');
    assert = env.require('cassert');
    _ = env.require('lodash');
    exec = Promise.promisify(require("child_process").exec);
    MaxThermostat = (function(_super) {
      __extends(MaxThermostat, _super);

      function MaxThermostat() {
        this.init = __bind(this.init, this);
        _ref = MaxThermostat.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      MaxThermostat.prototype.init = function(app, framework, config) {
        var deviceConfigDef,
          _this = this;
        this.framework = framework;
        this.config = config;
        this.checkBinary();
        deviceConfigDef = require("./device-config-schema");
        this.framework.deviceManager.registerDeviceClass("MaxThermostatDevice", {
          configDef: deviceConfigDef.MaxThermostatDevice,
          createCallback: function(config) {
            return new MaxThermostatDevice(config);
          }
        });
        return this.framework.on("after init", function() {
          var mobileFrontend;
          mobileFrontend = _this.framework.getPlugin('mobile-frontend');
          if (mobileFrontend != null) {
            mobileFrontend.registerAssetFile('js', "pimatic-max-thermostat/app/js.coffee");
            return mobileFrontend.registerAssetFile('html', "pimatic-max-thermostat/app/template.html");
          } else {
            return env.logger.warn("MaxThermostat could not find the mobile-frontend. No gui will be available");
          }
        });
      };

      MaxThermostat.prototype.checkBinary = function() {
        var command;
        command = "php " + plugin.config.binary;
        command += " " + plugin.config.host + " " + plugin.config.port;
        command += " " + this.config.RoomID + " " + this.config.deviceNo;
        command += "check";
        return exec(command)["catch"](function(error) {
          if (error.message.match("not found")) {
            return env.logger.error("max.php binary not found. Check your config!");
          } else {
            return env.logger.info("max.php binary found");
          }
        }).done();
      };

      return MaxThermostat;

    })(env.plugins.Plugin);
    plugin = new MaxThermostat;
    MaxThermostatDevice = (function(_super) {
      __extends(MaxThermostatDevice, _super);

      MaxThermostatDevice.prototype._mode = "auto";

      MaxThermostatDevice.prototype._settemperature = null;

      function MaxThermostatDevice(config) {
        this.config = config;
        this.id = deviceconfig.id;
        this.name = deviceconfig.name;
        this.getState();
        MaxThermostatDevice.__super__.constructor.call(this);
      }

      MaxThermostatDevice.prototype.getMode = function() {
        return Promise.resolve(this._mode);
      };

      MaxThermostatDevice.prototype.getSettemperature = function() {
        return Promise.resolve(this._settemperature);
      };

      MaxThermostatDevice.prototype._setMode = function(mode) {
        if (mode === this._mode) {
          return;
        }
        this._mode = mode;
        return this.emit("mode", this._mode);
      };

      MaxThermostatDevice.prototype._setTemp = function(settemperature) {
        if (settemperature === this._settemperature) {
          return;
        }
        this._settemperature = settemperature;
        return this.emit("settemperature", this._settemperature);
      };

      MaxThermostatDevice.prototype.getState = function() {
        var command,
          _this = this;
        if (this._state != null) {
          return Promise.resolve(this._state);
        }
        command = "php " + plugin.config.binary;
        command += " " + plugin.config.host + " " + plugin.config.port;
        command += " " + this.config.RoomID + " " + this.config.deviceNo;
        command += " status";
        return exec(command).then(function(streams) {
          var data, stderr, stdout;
          stdout = streams[0];
          stderr = streams[1];
          stdout = stdout.trim();
          data = JSON.parse(stdout);
          config.actTemp = data.actTemp;
          config.mode = data.mode;
          config.comfyTemp = data.comfyTemp;
          config.ecoTemp = data.ecoTemp;
          env.logger.info(command);
          _this._setMode(data.mode);
          _this._setTemp(data.actTemp);
          return plugin.framework.saveConfig();
        });
      };

      MaxThermostatDevice.prototype.changeModeTo = function(mode) {
        var command,
          _this = this;
        if (this.mode === mode) {
          return;
        }
        command = "php " + plugin.config.binary;
        command += " " + plugin.config.host + " " + plugin.config.port;
        command += " " + this.config.RoomID + " " + this.config.deviceNo;
        command += " mode x " + mode;
        return exec(command).then(function(streams) {
          var stderr, stdout;
          stdout = streams[0];
          stderr = streams[1];
          if (stderr.length !== 0) {
            env.logger.debug(stderr);
          }
          env.logger.info("Changed mode to " + mode);
          return _this._setMode(mode);
        });
      };

      MaxThermostatDevice.prototype.changeTemperatureTo = function(temperature) {
        var command,
          _this = this;
        if (this.settemperature === temperature) {
          return;
        }
        command = "php " + plugin.config.binary;
        command += " " + plugin.config.host + " " + plugin.config.port;
        command += " " + this.config.RoomID + " " + this.config.deviceNo;
        command += " temp " + temperature;
        return exec(command).then(function(streams) {
          var stderr, stdout;
          stdout = streams[0];
          stderr = streams[1];
          if (stderr.length !== 0) {
            env.logger.debug(stderr);
          }
          env.logger.info(command);
          env.logger.info("Changed temperature to " + temperature + " °C");
          return _this._setTemp(temperature);
        });
      };

      MaxThermostatDevice.prototype.getTemplateName = function() {
        return "MaxThermostatDevice";
      };

      return MaxThermostatDevice;

    })(env.devices.Device);
    return plugin;
  };

}).call(this);
