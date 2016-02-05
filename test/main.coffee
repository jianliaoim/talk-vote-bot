should = require 'should'
app = require '../app'
request = require 'supertest'

describe 'Bot', ->

  it 'should start vote in a channel', (done) ->

    request(app).post '/incoming'
    .set 'Content-Type': 'application/json'
    .send
      creator:
        _id: 1
        name: 'xxx'
      body: '开始投票 1,2'
      _roomId: 1
      event: 'message.create'
    .end (err, res) ->
      res.body.body.should.eql '''
      投票开始，操作选项：
      1. 计票："@我 选项1,选项2"（如需多选，可通过','分隔后发送给我）
      2. 查看结果："@我 查看结果"
      投票将在 1 小时后结束，请在结束时间前查看投票结果
      '''
      done err

  it 'should not start vote again in room 1', (done) ->

    request(app).post '/incoming'
    .set 'Content-Type': 'application/json'
    .send
      creator:
        _id: 1
        name: 'xxx'
      body: '开始投票，1,2'
      _roomId: 1
      event: 'message.create'
    .end (err, res) ->
      res.body.body.should.eql '上次投票尚未结束，请查看统计结果后再发起投票'
      done err

  it 'should record vote 1 of user xxx', (done) ->

    request(app).post '/incoming'
    .set 'Content-Type': 'application/json'
    .send
      creator:
        _id: 1
        name: 'xxx'
      body: '2'
      _roomId: 1
      event: 'message.create'
    .end (err, res) ->
      console.log "Vote result", res.body
      done err

  it 'should record vote 1, 2 of user yyy', (done) ->

    request(app).post '/incoming'
    .set 'Content-Type': 'application/json'
    .send
      creator:
        _id: 2
        name: 'yyy'
      body: '<$at|1|robot$> 1,2'
      _roomId: 1
      event: 'message.create'
    .end (err, res) ->
      done err

  it 'should get the final record of votes', (done) ->

    request(app).post '/incoming'
    .set 'Content-Type': 'application/json'
    .send
      creator:
        _id: 2
        name: 'yyy'
      body: '查看结果'
      _roomId: 1
      event: 'message.create'
    .end (err, res) ->
      res.body.body.should.eql '''
      投票选项：1,2
      总票数：3
      选项 2，票数 2 66.67% （xxx,yyy）
      选项 1，票数 1 33.33% （yyy）
      '''
      done err
