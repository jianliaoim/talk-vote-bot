express = require 'express'
logger = require 'graceful-logger'
config = require 'config'
morgan = require 'morgan'
bodyParser = require 'body-parser'
app = express()

bot = require './src/bot'

app.use morgan()
app.use bodyParser.json(limit: '10mb')
app.use bodyParser.urlencoded(extended: true, limit: '10mb')

app.bot = bot app

app.listen config.port, -> logger.info "Bot listen on #{config.port}"

module.exports = app
