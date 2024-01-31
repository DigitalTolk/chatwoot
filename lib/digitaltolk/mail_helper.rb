class Digitaltolk::MailHelper
  INVALID_LOOPIA_EMAIL = '{{email}}@loopia.invalid'
  EMAIL_REGEX = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/

  def self.email_from_body(html_content)
    match = html_content.match(EMAIL_REGEX)
    match[0]
  end

  def self.from_dt_webflow?(email)
    return false if email.blank?

    email == INVALID_LOOPIA_EMAIL
  end

  def self.auto_reply?(message)
    return false if message.blank?

    subject = message.content_attributes.dig(:email, :subject).to_s
    return true if subject.downcase.include?('auto')
    return true if message.content.to_s.downcase.include?('auto')

    # considered autoreply
    other_messages = message.conversation.messages.where.not(id: message.id)
    message.content.length > 5 && other_messages.where(content: message.content).exists?
  end
end