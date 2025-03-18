class PrivateChannelsChannel < ApplicationCable::Channel
  attr_accessor :receiver, :channel

  def subscribed
    stream_from "private_channel_creation:#{current_user.id}"
  end

  def create_channel(data)
    @receiver = User.find_by(id: data["receiver_id"])

    return transmit_error(invalid_receiver_error) if receiver.nil? || receiver == current_user

    @channel = find_or_create_private_channel

    NotificationsChannel.broadcast_to receiver, { action: "new_private_channel", channel_id: channel.id }

    transmit_success("private_channel_created", channel: channel_presenter)
  end

  private

  def invalid_receiver_error
    { code: "invalid_receiver", message: "Invalid receiver" }
  end

  def find_or_create_private_channel
    existing_channel = Channel.between_users(current_user, receiver).first

    return existing_channel if existing_channel

    ActiveRecord::Base.transaction do
      channel = current_user.created_channels.create!(public: false)
      channel.memberships.create!(user: current_user)
      channel.memberships.create!(user: receiver)
      channel
    end
  end

  def channel_presenter
    ChannelPresenter.new(channel).to_h
  end
end
