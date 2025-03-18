class DirectMessageChannel < ApplicationCable::Channel
  attr_accessor :channel, :message

  def subscribed
    @channel = current_user.private_channels.find_by(id: params["channel_id"])

    return transmit_and_reject("not_found", "Channel not found") unless channel

    stream_for channel
  end

  def receive(data)
    @message = channel.messages.create!(sender: current_user, content: data["content"])

    broadcast_message("new_message", { message: message_presenter })
  rescue ActiveRecord::RecordInvalid => e
    transmit_error({ code: "creation_failed", messages: e.record.errors.full_messages })
  end

  private

  def broadcast_message(action, payload)
    broadcast_to_channel(channel, action, payload.deep_stringify_keys) do |channel, payload|
      DirectMessageChannel.broadcast_to(channel, payload)
    end
  end

  def message_presenter
    MessagePresenter.new(message).to_h
  end
end
