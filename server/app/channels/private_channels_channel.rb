class PrivateChannelsChannel < ApplicationCable::Channel
  attr_accessor :receiver, :channel

  def subscribed
    stream_from "private_channels:#{current_user.id}"
  end

  def create_channel(data)
    @receiver = User.find_by(nickname: data["receiver_nickname"])

    return transmit_error(invalid_receiver_error) if receiver.nil? || receiver == current_user
    return transmit_error(channel_already_created) if existing_channel?
    find_or_create_private_channel!

    transmit_success("private_channel_created", channel: channel_presenter(channel, receiver))
  end

  def list_private_channels
    private_channels = current_user.private_channels
                                   .includes(memberships: :user)
                                   .ordered_by_activity
    result = private_channels.map do |channel|
      receiver = channel.memberships.find { |m| m.user_id != current_user.id }&.user
      channel_presenter(channel, receiver).to_h
    end

    transmit_success("private_channels", channels: result)
  end

  private

  def channel_already_created
    { code: "channel_already_created", message: "Canal ya creado, busca en la lista de mensajes directos!" }
  end

  def existing_channel?
    Channel.between_users(current_user, receiver).first.present?
  end

  def invalid_receiver_error
    { code: "invalid_receiver", message: "Invalid receiver" }
  end

  def find_or_create_private_channel!
    @channel = ActiveRecord::Base.transaction do
      channel = current_user.created_channels.create!(public: false)
      channel.memberships.create!(user: current_user)
      channel.memberships.create!(user: receiver)
      channel
    end

    broadcast_new_private_channel("new_private_channel", { channel: channel_presenter(channel, current_user) })
  end

  def broadcast_new_private_channel(action, payload)
    broadcast_to_channel(receiver, action, payload.deep_stringify_keys) do |channel, payload|
      NotificationsChannel.broadcast_to(channel, payload)
    end
  end

  def channel_presenter(channel, receiver)
    PrivateChannelPresenter.new(channel, receiver).to_h
  end
end
