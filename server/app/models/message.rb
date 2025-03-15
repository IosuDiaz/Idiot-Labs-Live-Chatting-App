class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :channel, optional: true

  validates :content, presence: true,
                      format: { with: /\A\S+.*\z/, message: "it cannot be black or just spaces" },
                      length: { maximum: 1000, message: "1000 characters max" },
                      format: { without: /<[^>]*>/, message: "HTML is not supported" }

  validates :sender, presence: true
  validates :channel, presence: true

  after_create :update_channel_last_message_at

  private

  def update_channel_last_message_at
    channel.update!(last_message_at: created_at)
  end
end
