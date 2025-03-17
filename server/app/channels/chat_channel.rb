class ChatChannel < ApplicationCable::Channel
  attr_accessor :channel, :membership

  def subscribed
    @channel = Channel.find_by(id: params[:channel_id])
    return transmit_and_reject("reject_subscription", "Channel not found") unless channel

    find_or_create_user_membership
    return transmit_and_reject("reject_subscription", "Membership is banned") if membership.banned?

    broadcast_user_action("user_joined") if membership.status == "active" && membership.saved_change_to_status?
    stream_for channel
  end

  def unsubscribed
    return unless channel

    membership = channel.memberships.find_by(user: current_user)

    if membership && membership.active?
      membership.update!(status: :inactive)
      action = "user_left"
      transmit_success(action, { user: user_presenter(current_user) })
      broadcast_user_action(action)
    end
  end

  private

  def transmit_and_reject(code, message)
    transmit_error({ code: code, message: message })
    reject
  end

  def broadcast_user_action(action)
    broadcast_to_channel(channel, action, { user: user_presenter(current_user) }.deep_stringify_keys) do |channel, payload|
      ChatChannel.broadcast_to(channel, payload)
    end
  end

  def find_or_create_user_membership
    @membership = current_user.memberships.find_or_initialize_by(channel: @channel)

    return membership.save! if membership.new_record?
    membership.update!(status: "active") if membership.inactive?
  end

  def user_presenter(user)
    UserPresenter.new(user).to_h
  end
end
