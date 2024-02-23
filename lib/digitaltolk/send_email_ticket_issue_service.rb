class Digitaltolk::SendEmailTicketIssueService
  attr_accessor :account, :user, :params, :errors, :conversation, :for_issue

  def initialize(account, user, params)
    @account = account
    @user = user
    @params = params
    @errors = []
    @for_issue = for_issue
  end

  def perform
    service = Digitaltolk::SendEmailTicketService.new(account, user, params, for_issue: true)
    result = service.perform
    @errors = service.errors
    
    result
  end
end