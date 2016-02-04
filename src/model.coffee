path = require 'path'
Datastore = require 'nedb'
config = require 'config'
moment = require 'moment'
Promise = require 'bluebird'
logger = require 'graceful-logger'
_ = require 'lodash'
fs = require 'fs'

dbs = {}

Promise.promisifyAll fs
Promise.promisifyAll Datastore.prototype

model =

  getDb: ->
    today = moment().format('YYYYMMDD')
    dbName = "checkin_#{today}.json"
    unless dbs[dbName]
      dbs[dbName] = new Datastore
        filename: path.join(config.dbPath, dbName)
        autoload: true
    dbs[dbName]

  destroyDb: ->
    today = moment().format('YYYYMMDD')
    dbName = "checkin_#{today}.json"
    delete dbs[dbName]
    fs.unlinkAsync path.join(config.dbPath, dbName)
    .catch (err) ->

  addCheckin: (checkinData) ->
    db = model.getDb()

    $firstCheckinData = db.findOneAsync _creatorId: checkinData._creatorId, type: 'first'

    .then (firstCheckinData) ->
      return firstCheckinData if firstCheckinData
      db.insertAsync _.assign {}, checkinData, type: 'first'

    $lastCheckinData = db.updateAsync
      _creatorId: checkinData._creatorId
      type: 'last'
    ,
      _.assign {}, checkinData, type: 'last'
    ,
      upsert: true
      returnUpdatedDocs: true

    Promise.all [$firstCheckinData, $lastCheckinData]

  getCheckins: ->
    db = model.getDb()
    db.findAsync({})

module.exports = model
