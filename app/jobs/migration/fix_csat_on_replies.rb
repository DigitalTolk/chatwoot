class Migration::FixCsatOnReplies < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    inbox_ids = Inbox.where(csat_survey_enabled: true, csat_trigger: 'conversation_all_reply')

    Rails.logger.debug { "csat_count: #{Message.count}" }
    Conversation.where(inbox_id: inbox_ids).find_each do |convo|
      next if convo.messages.outgoing.blank?

      template = convo.inbox.csat_template
      next if convo.messages.csat.count >= template.questions_count

      MessageTemplates::Template::CsatSurvey.new(conversation: convo).perform
    end
    Rails.logger.debug { "csat_count: #{Message.count}" }
  end
end