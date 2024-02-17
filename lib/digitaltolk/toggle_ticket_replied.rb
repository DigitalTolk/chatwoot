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
    # dt_url = "https://api-gateway.digitaltolk.se/api/v3/core/chatwoot/email/#{conversation_id}/response"
    dt_url = "https://api-gateway-stg.digitaltolk.com/api/v3/core/chatwoot/email/#{conversation_id}/response"
    headers = { 'Content-Type' => 'application/json' }
    data = {  is_ticket_replied: status }
    
    response = Net::HTTP.post(URI(dt_url), data.to_json, headers)
  rescue StandardError => e
    Rails.logger.error e
  end
end