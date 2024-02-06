class MessageTemplates::HookExecutionService
  pattr_initialize [:message!]

  def perform
    return if conversation.campaign.present?
    return if conversation.last_incoming_message.blank?

    trigger_templates
  end

  private

  delegate :inbox, :conversation, to: :message
  delegate :contact, to: :conversation
  delegate :csat_template, to: :inbox

  def trigger_templates
    ::MessageTemplates::Template::OutOfOffice.new(conversation: conversation).perform if should_send_out_of_office_message?
    ::MessageTemplates::Template::Greeting.new(conversation: conversation).perform if should_send_greeting?
    ::MessageTemplates::Template::EmailCollect.new(conversation: conversation).perform if inbox.enable_email_collect && should_send_email_collect?
    ::MessageTemplates::Template::CsatSurvey.new(conversation: conversation).perform if should_send_csat_survey?
  end

  def should_send_out_of_office_message?
    # should not send if its a tweet message
    return false if conversation.tweet?
    # should not send for outbound messages
    return false unless message.incoming?

    inbox.out_of_office? && conversation.messages.today.template.empty? && inbox.out_of_office_message.present?
  end

  def first_message_from_contact?
    conversation.messages.outgoing.count.zero? && conversation.messages.template.count.zero?
  end

  def should_send_greeting?
    # should not send if its a tweet message
    return false if conversation.tweet?

    first_message_from_contact? && inbox.greeting_enabled? && inbox.greeting_message.present?
  end

  def email_collect_was_sent?
    conversation.messages.where(content_type: 'input_email').present?
  end

  # TODO: we should be able to reduce this logic once we have a toggle for email collect messages
  def should_send_email_collect?
    !contact_has_email? && inbox.web_widget? && !email_collect_was_sent?
  end

  def contact_has_email?
    contact.email
  end

  def csat_enabled_conversation?
    return false unless conversation.resolved? || (message.outgoing? && inbox.csat_trigger == 'conversation_all_reply')
    # should not sent since the link will be public
    return false if conversation.tweet?
    return false unless inbox.csat_survey_enabled?

    true
  end

  def should_send_csat_survey?
    return unless csat_enabled_conversation?

    if inbox.csat_template_enabled?
      last_csat_reached = conversation.messages.csat.count >= csat_template.questions_count
      if inbox.email?
        return if last_csat_reached
      else
        return if last_csat_reached || conversation.messages.unanswered_csat.exists?
      end
    elsif conversation.messages.csat.present?
      return
      # only send CSAT once in a conversation
    end

    true
  end
end
MessageTemplates::HookExecutionService.prepend_mod_with('MessageTemplates::HookExecutionService')
