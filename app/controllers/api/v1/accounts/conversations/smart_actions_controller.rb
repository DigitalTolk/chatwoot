class Api::V1::Accounts::Conversations::SmartActionsController < Api::V1::Accounts::Conversations::BaseController
  def index
    @smart_actions = @conversation.smart_actions
  end

  def create
    @smart_action = SmartActionBuilder.new(@conversation, params).perform

    render json: { success: @smart_action.present? }
  end
end
