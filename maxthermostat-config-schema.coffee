module.exports = {
  title: "max-thermostat config"
  type: "object"
  properties:
    host:
      description: "The IP of the MAX! Cube"
      type: "string"
      default: "127.0.0.1"
    port:
      description: "The port of the MAX! Cube (Default: 62910)"
      type: "integer"
      default: 62910
    debug:
      description: "Output update message from cube and additional infos"
      type: "boolean"
      default: true
}