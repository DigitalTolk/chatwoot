class NotificationBuilder
  pattr_initialize [:notification_type!, :user!, :account!, :primary_actor!]

  def perform
    return unless user_subscribed_to_notification?

    build_notification
  end

  private

  def secondary_actor
    Current.user
  end

  def user_subscribed_to_notification?
    notification_setting = user.notification_settings.find_by(account_id: account.id)
    # added for the case where an assignee might be removed from the account but remains in conversation
    return if notification_setting.blank?

    return true if notification_setting.public_send("email_#{notification_type}?")
    return false unless primary_actor.inbox.push_notification_enabled?
    return true if notification_setting.public_send("push_#{notification_type}?")

    false
  end

  def build_notification
    user.notifications.create!(
      notification_type: notification_type,
      account: account,
      primary_actor: primary_actor,
      secondary_actor: secondary_actor
    )
  end
end
