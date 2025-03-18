class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  enum :role, { member: 0, creator: 1 }, default: :member
  enum :status, { active: 0, inactive: 1, banned: 2 }, default: :active

  validates :user_id, uniqueness: { scope: :channel_id, message: "is already joined" }
  validate :user_must_be_confirmed

  validates :status, inclusion: { in: statuses.keys }

  private

  def user_must_be_confirmed
    errors.add(:user, "must be confirmed") unless user.confirmed?
  end
end
