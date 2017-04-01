require 'sinatra'
require 'json'

get '/' do
  'sup'
end

post '/webhooks/sparkpost' do
  request.body.rewind
  json = JSON.parse(request.body.read)

  logger.info "new mail: #{json}"
end
