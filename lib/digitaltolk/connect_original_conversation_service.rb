class Digitaltolk::ConnectOriginalConversationService
  attr_accessor :conversation, :original_conversation
  include Rails.application.routes.url_helpers

  def initialize(conversation, original_conversation)
    @conversation = conversation
    @old_conversation = old_conversation
  end

  def perform
    mb = Messages::MessageBuilder.new(@user, @conversation.reload, private_message_params)
    mb.perform
  end

  private

  def private_message_params
    { 
      content: "This conversation originates from [#{@old_conversation.display}](#{original_url})", 
      private: true
    }
  end

  def original_url
    app_account_conversation_path(account_id: @old_conversation.account_id, id: @old_conversation.display_id)
  end
end