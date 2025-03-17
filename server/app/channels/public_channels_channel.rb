class PublicChannelsChannel < ApplicationCable::Channel
  attr_reader :channel

  def subscribed
    stream_from "public_channels"
  end

  def list_public_channels
    channels = public_channels.map { |channel| channel_presenter(channel) }
    transmit_success("public_channels", channels: channels)
  end

  def list_users(data)
    channel = public_channels.find(data["channel_id"])
    users_data = channel.users.map { |user| user_presenter(user) }

    transmit_success("channel_users", users: users_data)
  rescue ActiveRecord::RecordNotFound => e
    transmit_error(code: "not_found", message: e.message)
  end

  def create_public_channel(data)
    ActiveRecord::Base.transaction do
      create_channel!(data)
    end

    transmit_success("channel_created", channel: channel_presenter(channel))
    broadcast_to_public_channels(channel)
  rescue ActiveRecord::RecordInvalid => e
    transmit_error(code: "creation_failed", messages: e.record.errors.full_messages)
  end

  private

  def public_channels
    Channel.public_channels
  end

  def create_channel!(data)
    @channel = current_user.created_channels.create!(
      name: data["name"],
      description: data["description"],
      public: true
    )
  end

  def broadcast_to_public_channels(channel)
    broadcast_to_channel(
      "public_channels",
      "user_joined",
      { user: user_presenter(current_user) }.deep_stringify_keys
    ) do |channel, payload|
      ActionCable.server.broadcast(channel, payload)
    end
  end

  def channel_presenter(channel)
    ChannelPresenter.new(channel).to_h
  end

  def user_presenter(user)
    UserPresenter.new(user).to_h
  end
end
