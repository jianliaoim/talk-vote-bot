config = require 'config'
cron = require 'cron'
_ = require 'lodash'
Promise = require 'bluebird'
logger = require 'graceful-logger'
moment = require 'moment'
{CronJob} = cron
request = require 'request'

requestAsync = Promise.promisify request

model = require './model'
rules = require './rules'

class Bot

  isActive: ->
    config.activeDate is moment().format('YYYYMMDD')

  active: ->
    config.activeDate = moment().format('YYYYMMDD')

bot = new Bot

_messageHandler = (req, res) ->
  return res.status(400).send("Missing creator") unless req.body.creator

  # 动态记录频道 id，以便发送记录
  if req.body._storyId
    config._targetId = req.body._storyId
    config.targetType = 'story'
  else if req.body._roomId
    config._targetId = req.body._roomId
    config.targetType = 'room'

  bot.active()

  checkinData =
    _creatorId: req.body.creator._id
    name: req.body.creator.name
    time: Date.now()

  model.addCheckin checkinData

  .then ->

    # 提取回复规则
    replyRule = null
    rules.replies.some (reply) ->
      switch
        when reply.match and req.body.body?.match(reply.match)
          replyRule = reply
          return true
        else return false

    return res.status(200).send('ok') unless replyRule

    # 构造回复消息
    replyMsg = null

    switch
      when replyRule.msg
        replyRule.msg = [replyRule.msg] if toString.call(replyRule.msg) is '[object String]'
        replyMsg = replyRule.msg[_.random(0, replyRule.msg.length - 1)]

    return res.status(200).send('ok') unless replyMsg

    # 预处理回复消息
    if rules.replaces
      for key, val of rules.replaces
        replyMsg = replyMsg.replace key, val

    # 构造消息结构
    message = content: replyMsg
    # 回应消息
    res.status(200).send message

  .catch (err) -> res.status(400).send error: err.message

_sendCheckinSummary = ->
  return unless bot.isActive()
  return unless rules.members and config._targetId and config.webhookUrl
  model.getCheckins().then (checkins) ->
    _checkinIds = checkins.map (checkin) -> "#{checkin._creatorId}"
    checkinNames = checkins.map (checkin) -> "#{checkin.name}"
    nonCheckMembers = rules.members.filter (memberName) ->
      return false if memberName in _checkinIds
      return false if checkinNames.some (name) -> name?.indexOf(memberName) > -1
      return true
    if nonCheckMembers.length
      msg = "#{nonCheckMembers.join('，')} 这几个家伙还没签到，去哪儿啦？"
    else
      msg = "大家来的好早，每一位都签到啦"

    message = content: msg

    switch config.targetType
      when 'story' then message._storyId = config._targetId
      when 'room' then message._roomId = config._targetId
      else return false

    requestAsync
      method: 'POST'
      url: config.webhookUrl
      json: true
      body: message

  .catch (err) -> logger.warn err.stack

_sendCronData = (cronData) ->

  return ->

    return unless bot.isActive()
    return unless config.webhookUrl and config._targetId and cronData.msg

    message = content: cronData.msg

    switch config.targetType
      when 'story' then message._storyId = config._targetId
      when 'room' then message._roomId = config._targetId
      else return false

    requestAsync
      method: 'POST'
      url: config.webhookUrl
      json: true
      body: message
    .catch (err) -> logger.warn err.stack

module.exports = (app) ->

  app.post '/incoming', (req, res) ->
    _messageHandler req, res

  app.use (err, req, res, next) ->
    res.status(500).send error: err.message

  new CronJob('0 0 10 * * 1-5', _sendCheckinSummary).start()

  if rules.crons
    for cronRule, cronData of rules.crons
      new CronJob(cronRule, _sendCronData(cronData)).start()

  bot
