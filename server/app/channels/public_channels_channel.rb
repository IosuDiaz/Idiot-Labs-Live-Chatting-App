class PublicChannelsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "public_channels"
  end

  def list_public_channels
    channels = Channel.public_channels.map { |channel| channel_presenter(channel) }

    transmit({ type: "public_channels", data: channels })
  rescue => e
    transmit({ error: "Error al obtener canales" })
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
