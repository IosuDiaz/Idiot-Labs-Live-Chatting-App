class PublicChannelsChannel < ApplicationCable::Channel
  attr_reader :channel

  def subscribed
    stream_from "public_channels"
  end

  def list_public_channels
    channels = Channel.public_channels.map { |channel| channel_presenter(channel) }
    transmit_success("public_channels", channels: channels)
  end

  def create_public_channel(data)
    create_channel!(data)

    transmit_success("channel_created", channel: channel_presenter(channel))
    broadcast_to_public_channels(channel)
  rescue ActiveRecord::RecordInvalid => e
    transmit_error(code: "creation_failed", messages: e.record.errors.full_messages)
  end

  private

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
      "channel_created",
      { channel: channel_presenter(channel) }.deep_stringify_keys
    ) do |channel, payload|
      ActionCable.server.broadcast(channel, payload)
    end
  end

  def channel_presenter(channel)
    ChannelPresenter.new(channel).to_h
  end
end
