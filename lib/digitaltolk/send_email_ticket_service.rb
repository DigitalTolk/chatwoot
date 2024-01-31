class Digitaltolk::SendEmailTicketService
  attr_accessor :account, :user, :params, :errors, :conversation

  def initialize(account, user, params)
    @account = account
    @user = user
    @params = params
    @errors = []
  end

  def perform
    find_conversation
    validate
    create_message
    result_data
  end

  private

  def result_data
    return result_json(true, "Email sent!") if @errors.blank?

    result_json(false, @errors.join(", "))
  end

  def result_json(success, message)
    {
      success: success,
      message: message
    }
  end

  def conversations
    @account.where(conversation_id: account)
  end

  def find_conversation
    @conversation = Conversation.where("custom_attributes ->> 'booking_id' = ?", booking_id).last
  end

  def booking_id
    params.dig(:booking_id)
  end

  def validate
    if booking_id.blank?
      @errors << "Parameter booking_id is required."
    end

    #validate email address

    if @conversation.blank?
      @errors << "Conversation with booking number #{booking_id} not found"
    end
  end

  def create_message
    return if @errors.present?

    @message = @conversation.messages.build(message_params)
    @message.save!
  end

  def message_type
    'outgoing'
  end

  def message_params
    {
      account_id: @conversation.account_id,
      inbox_id: @conversation.inbox_id,
      message_type: message_type,
      content: @params[:body],
      private: false,
      sender: user,
      content_type: 'input_email',
    }
  end
end