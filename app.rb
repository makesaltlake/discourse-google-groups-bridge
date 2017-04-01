require 'sinatra'
require 'json'
require 'email_reply_trimmer'
require 'base64'
require 'mail'

get '/' do
  'sup'
end

post '/webhooks/sparkpost' do
  halt 403 unless ENV.fetch('SPARKPOST_INBOUND_AUTH_TOKEN') == request.env['HTTP_X_MESSAGESYSTEMS_WEBHOOK_TOKEN']

  request.body.rewind
  json = JSON.parse(request.body.read)

  json.each do |mail|
    content = mail['msys']['relay_message']['content']['email_rfc822']
    content = Base64.decode64(content) if mail['msys']['relay_message']['content']['email_rfc822_is_base64']

    mail = Mail.new(content)
    mail = mail.text_part if mail.multipart?

    unless mail.content_type.to_s.include?('text/plain')
      logger.info 'mail appears to be HTML only, bailing'
      return
    end

    body = EmailReplyTrimmer.trim(mail.body.decoded)

    logger.info "new mail: #{body}"
  end

  nil
end
