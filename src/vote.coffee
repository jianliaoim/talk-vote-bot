###*
 * Record vote session
###

# voteData =
#   userId1:
#     name: 'xxxx'
#     votes: [1, 2, 3]
#   userId2:
#     name: 'yyyy'
#     votes: [2, 3]
#
# totalNumber = 10
#
# indexedVotes =
#   option1:
#     number: 2
#     users: [userName1, userName2]
#   option2:
#     number: 3
#     users: [userName1, userName2]

class VoteSession

  constructor: ->
    @startAt = new Date
    @voteData = {}

  start: (message) ->
    @voteOptions = message.body
      .replace /\<\$(.*?)\$\>/g, ''
      .replace /开始投票|start/ig, ''
      .trim()

    '''
    投票开始，操作选项：
    1. 计票："@我 选项1,选项2"（如需多选，可通过','分隔后发送给我）
    2. 查看结果："@我 查看结果"
    投票将在 1 小时后结束，请在结束时间前查看投票结果
    '''

  vote: (message) ->

    # 移除@部分
    voteBody = message.body.replace /\<\$(.*?)\$\>/g, ''
    user = message.creator

    votes = voteBody
      .split ','
      .map (vote) -> vote.trim()
      .filter (vote) -> vote.length

    replyMsg = undefined

    replyMsg = '你已进行过投票，将以最后一次投票结果为准' if @voteData[user._id]

    @voteData[user._id] =
      name: user.name
      votes: votes

    replyMsg

  result: ->
    voteData = @voteData

    totalNumber = 0
    indexedVoteData = {}

    for userId, vote of voteData
      vote.votes.forEach (voteOption) ->
        totalNumber += 1
        indexedVoteData[voteOption] or= number: 0, users: []
        indexedVoteData[voteOption].number += 1
        indexedVoteData[voteOption].users.push vote.name

    resultData = Object.keys(indexedVoteData).sort (x, y) ->
      return if indexedVoteData[y].number > indexedVoteData[x].number then 1 else -1
    .map (voteOption) ->
      number = indexedVoteData[voteOption].number
      users = indexedVoteData[voteOption].users
      "选项 #{voteOption}，票数 #{number} #{Math.round(number / totalNumber * 10000) / 100}% （#{users.join(',')}）"

    """
    投票选项：#{@voteOptions}
    总票数：#{totalNumber}
    #{resultData.join('\n')}
    """

module.exports = VoteSession
