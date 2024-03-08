# housekeeping
# remove contact inboxes that does not have any conversations
# and are older than 3 months

class Internal::RemoveStaleConversationsJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    Digitaltolk::CloseResolvedConversationService.new.perform
  end
end
