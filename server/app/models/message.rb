class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User", optional: true
  belongs_to :channel, optional: true

  validates :content, presence: true,
                      format: { with: /\A\S+.*\z/, message: "it cannot be black or just spaces" },
                      length: { maximum: 1000, message: "1000 characters max" },
                      format: { without: /<[^>]*>/, message: "HTML is not supported" }

  validate :channel_xor_receiver_presence
  validates :receiver, presence: { message: "must exist" }, if: -> { receiver_id.present? }
  validates :channel, presence: { message: "must exist" }, if: -> { channel_id.present? }

  validate :prevent_self_messaging

  scope :between_users, ->(user1, user2, options = {}) {
    order = options.fetch(:order, :desc)
    where(sender: user1, receiver: user2)
      .or(where(sender: user2, receiver: user1))
      .order(created_at: order)
  }

  private

  def direct_message?
    receiver.present? && channel.blank?
  end

  def prevent_self_messaging
    return unless direct_message?

    if sender == receiver
      errors.add(:receiver_id, "You cannot send direct messages to yourself.")
    end
  end

  def channel_xor_receiver_presence
    if channel.blank? && receiver.blank?
      errors.add(:base, "The message have to be for a channel or a user")
    elsif channel.present? && receiver.present?
      errors.add(:base, "The message cannot be for a channel and a user at the same time")
    end
  end
end
