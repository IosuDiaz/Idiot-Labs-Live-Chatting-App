class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_secure_password

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

  after_create :generate_validation_link

  private

  def generate_validation_link
    SendConfirmationService.generate(self)
  end
end
