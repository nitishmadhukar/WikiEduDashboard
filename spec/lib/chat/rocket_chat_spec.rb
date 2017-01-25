# frozen_string_literal: true
require 'rails_helper'
require "#{Rails.root}/lib/chat/rocket_chat"

describe RocketChat do
  let(:user) { nil }
  let(:course) { nil }
  let(:subject) { RocketChat.new(user: user, course: course) }

  describe '#login_credentials' do
    let(:user) { create(:user, chat_password: chat_password) }

    context 'when the user already has a Rocket.Chat account' do
      let(:chat_password) { 'random_password' }
      before { stub_chat_login_success }
      it 'returns an authToken and userId' do
        expect(subject.login_credentials).to eq('authToken' => 'fakeAuthToken',
                                                'userId' => 'chatIdForUser')
      end
    end

    context 'when the user does not have a chat account' do
      let(:chat_password) { nil }
      before do
        stub_chat_login_success
        stub_chat_user_create_success
      end

      it 'creates an account, then returns an authToken and userId' do
        expect(subject.login_credentials).to eq('authToken' => 'fakeAuthToken',
                                                'userId' => 'chatIdForUser')
      end

      it 'saves the user\'s chat password' do
        expect(user.chat_password).to be_nil
        subject.login_credentials
        expect(user.chat_password).not_to be_nil
      end
    end
  end

  describe '#create_channel_for_course' do
    let(:course) { create(:course) }

    before do
      stub_chat_login_success
      stub_chat_channel_create_success
    end

    it 'returns Rocket.Chat response' do
      response = subject.create_channel_for_course
      expect(JSON.parse(response.body).dig('success')).to eq(true)
    end
  end
end
