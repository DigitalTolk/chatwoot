class LogConversation < ActiveRecord::Migration[7.0]
  def change
    conversation = Conversation.find_by(display_id: 33_053)

    return if conversation.blank?

    Rails.logger.warn 'logging conversation'
    Rails.logger.warn conversation.attributes
    conversation.messages.each do |msg|
      Rails.logger.warn msg.attributes
    end
  end
end
