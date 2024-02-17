class Digitaltolk::ToggleTicketReplied
  attr_accessor :conversation_id, :status

  ALLOWED_INBOXES = [386]

  def initialize(conversation_id, status)
    @conversation_id = conversation_id
    @status = status
  end

  def perform
    post_status
  end

  private

  def post_status
    puts "ticket_replied: #{status} for #{conversation_id}"
    response = Net::HTTP.post(URI(digitaltolk_url), data.to_json, headers)
  rescue StandardError => e
    Rails.logger.error e
  end

  def digitaltolk_url
    # https://api-gateway.digitaltolk.se/api/v3/core/chatwoot/email/%d/response
    "https://api-gateway-stg.digitaltolk.com/api/v3/core/chatwoot/email/#{conversation_id}/response"
  end

  def headers
    { 'Content-Type' => 'application/json' }
  end

  def data
    { is_ticket_replied: status }
  end
end