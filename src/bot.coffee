config = require 'config'
model = require './model'

class Bot

module.exports = (app) ->

  bot = new Bot

  app.post '/messages', (req, res) ->

    return res.status(400).send({error: "Missing creator"}) unless req.body.creator

    checkinData =
      _creatorId: req.body.creator._id
      name: req.body.creator.name
      time: Date.now()

    model.addCheckin checkinData

    .then -> res.status(200).send ok: 1

    .catch (err) -> res.status(400).send error: err.message

  bot
