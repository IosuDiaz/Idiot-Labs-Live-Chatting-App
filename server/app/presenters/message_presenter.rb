class MessagePresenter
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def to_h
    {
      id: message.id,
      content: message.content,
      sender: UserPresenter.new(message.sender).to_h,
      created_at: message.created_at
    }
  end
end
