filter = '''
- node_modules
- .git
- test
'''

sneaky 'ws', ->
  @user = 'jarvis'
  @path = '/usr/local/teambition/talk-checkin-bot'
  @filter = filter
  @host = 'talk.ci'
  @after '''
  mkdir -p ../share/node_modules \
  && ln -sfn ../share/node_modules . \
  && rm -rf config \
  && ln -sfn ../share/config . \
  && npm i --production && pm2 restart talk-checkin-bot
  '''

sneaky 'prod', ->
  @user = 'jarvis'
  @path = '/data/app/talk-checkin-bot'
  @filter = filter
  @host = '120.26.2.181'
  @after '''
  mkdir -p ../share/node_modules \
  && ln -sfn ../share/node_modules . \
  && rm -rf config \
  && ln -sfn ../share/config . \
  && npm i --production && pm2 restart talk-checkin-bot
  '''
