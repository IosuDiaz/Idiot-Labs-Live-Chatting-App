class Channel < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :messages, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  scope :public_channels, -> {
    where(public: true)
      .includes(:creator)
      .order(created_at: :desc)
  }

  scope :ordered_by_activity, -> { order(last_message_at: :desc) }

  validates :name,
    presence: true,
    uniqueness: {
      case_sensitive: false,
      scope: :public,
      conditions: -> { where(public: true) }
    },
    format: {
      with: /\A[\w-]+\z/,
      message: "just letters, numbers, scores and underscores allowed"
    },
    if: :public?

  validates :description, length: { maximum: 500 }, if: :public?
  validate :private_channel_has_no_name, unless: :public?
  validate :creator_must_be_confirmed

  after_create :create_creator_membership

  private

  def create_creator_membership
    memberships.create!(
      user: creator,
      role: :creator,
      status: :active
    )
  end

  def private_channel_has_no_name
    return unless name.present?

    errors.add(:name, "Private channels does not support names")
  end

  def creator_must_be_confirmed
    return if creator&.confirmed?

    errors.add(:creator, "must be confirmed to create a channel")
  end
end
