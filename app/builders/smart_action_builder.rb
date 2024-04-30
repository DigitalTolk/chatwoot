class SmartActionBuilder
  attr_accessor :errors

  def initialize(conversation, params)
    @conversation = conversation
    @params = params
  end

  def perform
    build_smart_action
  end

  private

  def build_smart_action
    return if smart_action_params.blank?

    @smart_action = @conversation.smart_actions.create(custom_attributes_params)
  end

  def smart_action_params
    @params [:smart_action]
  end

  def custom_attributes_params
    @params .require(:smart_action).permit(
      :name, 
      :label, 
      :description,
      :event,
      :intent_type,
      :message_id,
      :to,
      :from,
      :link
    )
  end
end
  