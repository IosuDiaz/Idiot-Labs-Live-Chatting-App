class PrivateChannelPresenter
  attr_reader :channel, :receiver

  def initialize(channel, receiver)
    @channel = channel
    @receiver = receiver
  end

  def to_h
    {
      id: channel.id,
      name: receiver.nickname,
      last_activity: (channel.last_message_at || channel.created_at)
    }
  end
end
