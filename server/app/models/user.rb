class User < ApplicationRecord
  has_secure_password

  has_many :memberships
  has_many :channels, through: :memberships

  has_many :created_channels,
    class_name: "Channel",
    foreign_key: "creator_id",
    dependent: :destroy

  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "invalid format" }

  validates :nickname,
    presence: true,
    uniqueness: true,
    length: { in: 3..20 },
    format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only letters, numbers and _" }

  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  after_create :send_confirmation_instructions

  private

  def send_confirmation_instructions
    SendConfirmationService.generate(self)
  end
end
