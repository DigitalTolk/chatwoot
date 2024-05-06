require 'rails_helper'

RSpec.describe SmartActionBuilder, type: :model do
  subject(:smart_action_builder) { described_class.new(conversation, params) }

  let(:conversation) { create(:conversation) }
  # let!(:current_user) { create(:user, account: account) }
  # let(:email) { 'test@example.com' }
  # let(:name) { 'Test User' }
  # let(:role) { 'agent' }
  # let(:availability) { 'offline' }
  # let(:auto_offline) { false }
  let(:params) do
    {
      email: email,
      name: name,
      inviter: current_user,
      account: account,
      role: role,
      availability: availability,
      auto_offline: auto_offline
    }
  end

  describe '#perform' do
    context 'when user does not exist' do
      it 'creates a new user' do
        expect { agent_builder.perform }.to change(User, :count).by(1)
      end
    end
 end
end