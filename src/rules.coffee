moment = require 'moment'

module.exports = rules =
  replies: [
    match: /.*/
    msg: [
      '%welcome，安排一下今天的计划吧~'
      '%welcome，我是偷工减料的签到机器人'
      '我实在是找不出还有什么话能回复了'
      '您先忙着，我去去就来'
      '你是猴子请来的救兵吗'
      '我喊你一声你敢应吗'
    ]
  ]
  # 列表中的成员如果没有签到，会在 10 点收到通知
  members: [
    '博深'
    '陈涌'
    '丹青'
    '品章'
    '砰砰'
    '王连杰'
    '王卫'
    '晶鑫'
    '王艺霖'
    '徐亮'
    '郁飞'
    '晓连'
    '俊官'
  ]
  # 替换 msg 中的字符串
  replaces:
    '%welcome': ->
      txt = ''
      hour = moment().hour()
      switch
        when hour > 7 and hour < 9 then txt = '早上好'
        when hour >= 9 and hour < 11 then txt = '上午好'
        when hour >= 11 and hour < 13 then txt = '中午好'
        when hour >=13 and hour < 18 then txt = '下午好'
        else txt = '晚上好'
      txt
  crons:
    '0 0 18 * * 1-5':
      msg: '忙碌了一天，大家都辛苦啦，好好休息吧'
