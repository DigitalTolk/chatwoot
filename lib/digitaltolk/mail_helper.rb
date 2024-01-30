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
end