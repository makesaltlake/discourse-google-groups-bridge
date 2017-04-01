require 'sinatra'
require 'json'

get '/' do
  'sup'
end

post '/webhooks/sparkpost' do
  halt 403 unless ENV.fetch('SPARKPOST_INBOUND_AUTH_TOKEN') == request.env['HTTP_X_MESSAGESYSTEMS_WEBHOOK_TOKEN']

  request.body.rewind
  json = JSON.parse(request.body.read)

  logger.info "new mail: #{json}"
end
