class ChatChannel < ApplicationCable::Channel
  attr_accessor :channel, :membership, :message

  def subscribed
    @channel = Channel.find_by(id: params[:channel_id])
    return transmit_and_reject("reject_subscription", "Channel not found") unless channel

    find_or_create_user_membership
    return transmit_and_reject("reject_subscription", "Membership is banned") if membership.banned?

    broadcast_action("user_joined", { user: user_presenter }) if should_broadcast?
    stream_for channel
  end

  def receive(data)
    @message = channel.messages.create!(sender: current_user, content: data["content"])

    broadcast_action("new_message", { message: message_presenter })
  rescue ActiveRecord::RecordInvalid => e
    transmit_error({ code: "creation_failed", messages: e.record.errors.full_messages })
  end

  def unsubscribed
    return unless channel

    membership = channel.memberships.find_by(user: current_user)

    if membership && membership.active?
      membership.update!(status: :inactive)
      action = "user_left"
      payload = { user: user_presenter }
      transmit_success(action, payload)
      broadcast_action(action, payload)
    end
  end

  private

  def should_broadcast?
    membership.status == "active" && membership.saved_change_to_status?
  end

  def transmit_and_reject(code, message)
    transmit_error({ code: code, message: message })
    reject
  end

  def broadcast_action(action, payload)
    broadcast_to_channel(channel, action, payload.deep_stringify_keys) do |channel, payload|
      ChatChannel.broadcast_to(channel, payload)
    end
  end

  def find_or_create_user_membership
    @membership = current_user.memberships.find_or_initialize_by(channel: @channel)

    return membership.save! if membership.new_record?
    membership.update!(status: "active") if membership.inactive?
  end

  def user_presenter
    UserPresenter.new(current_user).to_h
  end

  def message_presenter
    MessagePresenter.new(message).to_h
  end
end
