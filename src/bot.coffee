config = require 'config'
_ = require 'lodash'
Promise = require 'bluebird'
logger = require 'graceful-logger'
VoteSession = require './vote'

class Bot

bot = new Bot

# Record working vote sessions
voteSessionMap = {}

setInterval ->
  for voteSessionId, voteSession of voteSessionMap
    if (Date.now() - voteSession.startAt) > 3600000
      logger.warn "Clean up vote session for timeout", voteSessionId
      delete voteSessionMap[voteSessionId]
, 60000

_messageHandler = (req, res, next) ->
  # Ignore messages without body and creator
  message = req.body or {}
  unless message.creator and
         message.body and
         (message._roomId or message._storyId)
    return next()

  replyMsg = {}

  voteSessionId = message._roomId or message._storyId

  voteSession = voteSessionMap[voteSessionId]

  if message.body.match /开始投票|start/i

    if voteSession
      replyMsg.body = "上次投票尚未结束，请查看统计结果后再发起投票"
    else
      voteSessionMap[voteSessionId] = voteSession = new VoteSession
      replyMsg.body = voteSession.start message

  else if message.body.match /查看结果|result/i

    if voteSession
      replyMsg.body = voteSession.result()
      delete voteSessionMap[voteSessionId]
    else
      replyMsg.body = '无投票记录，请重新发起投票'

  else if voteSession
    replyMsg.body = voteSession.vote message

  res.status(200).send replyMsg

module.exports = (app) ->

  app.post '/incoming', (req, res) -> _messageHandler req, res

  app.use (req, res, next) -> res.status(200).send ok: 1

  app.use (err, req, res, next) ->
    logger.warn err.stack
    res.status(500).send error: err.message

  bot
