class ChannelPresenter
  attr_reader :channel

  def initialize(channel)
    @channel = channel
  end

  def to_h
    {
      id: channel.id,
      name: channel.name,
      description: channel.description,
      creator: {
        id: channel.creator.id,
        nickname: channel.creator.nickname
      },
      members_count: channel.memberships.active.count,
      last_activity: (channel.last_message_at || channel.created_at).to_s
    }
  end
end
