class Migration::FixCsatOnReplies < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    inbox_ids = Inbox.where(csat_survey_enabled: true, csat_trigger: 'conversation_all_reply')

    puts "csat count: #{Message.count}"
    Conversation.where(inbox_id: inbox_ids).each do |convo|
      template = convo.inbox.csat_template
      next if convo.messages.csat.count >= template.questions_count

      # fix
      MessageTemplates::Template::CsatSurvey.new(conversation: convo).perform
    end
    puts "csat count: #{Message.count}"
  end
end