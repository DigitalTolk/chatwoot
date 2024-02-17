class Conversations::DigitaltolkReplyStatusJob < ApplicationJob
  queue_as :high

  def perform(conversation_id, status)
    Digitaltolk::ToggleTicketReplied.new(conversation_id, status).perform
  end
end
