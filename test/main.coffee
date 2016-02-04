should = require 'should'
fs = require 'fs'
moment = require 'moment'
app = require '../app'
model = require '../src/model'
request = require 'supertest'

cleanup = (done) -> model.destroyDb().nodeify done

describe 'Bot', ->

  before cleanup

  it 'should record the first checkin time of user', (done) ->

    request(app).post '/incoming'
    .set 'Content-Type': 'application/json'
    .send
      creator:
        _id: 1
        name: 'xxx'
      body: 'Hello'
      event: 'message.create'
    .end (err, res) ->
      res.statusCode.should.eql 200
      done err

  it 'should update the last visit time of user', (done) ->

    # Checkin again
    request(app).post '/incoming'
    .set 'Content-Type': 'application/json'
    .send
      creator:
        _id: 1
        name: 'xxx'
      body: 'Hello Again'
      event: 'message.create'
    .end (err, res) ->
      res.statusCode.should.eql 200
      done err

  it 'should get all the checkin data', (done) ->

    model.getCheckins()

    .then (datas) ->
      datas.length.should.eql 2
      datas.forEach (data) -> data._creatorId.should.eql 1
      datas.sort (x, y) -> if x.time > y.time then -1 else 1
      datas[0].type.should.eql 'last'
      datas[1].type.should.eql 'first'

    .nodeify done

  after cleanup
