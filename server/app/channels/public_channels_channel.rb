class PublicChannelsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "public_channels"
  end

  def list_public_channels
    channels = Channel.public_channels.map { |channel| ChannelPresenter.new(channel).to_h }

    transmit({ type: "public_channels", data: channels })
  end

  def list_users(data)
    channel = Channel.public_channels.find(data["channel_id"])
    users_data = channel.users.map { |user| UserPresenter.new(user).to_h }
    transmit({ type: "channel_users", data: users_data })

  rescue ActiveRecord::RecordNotFound => e
    transmit_error(type: "not_found", message: e.message, code: 404)
  end

  private

  def channel_presenter(channel)
    {
      id: channel.id,
      name: channel.name,
      description: channel.description,
      creator: {
        id: channel.creator.id,
        nickname: channel.creator.nickname
      },
      members_count: channel.memberships.count,
      last_activity: channel.last_message_at || channel.created_at
    }
  end
end
