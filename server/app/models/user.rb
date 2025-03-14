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
    payload = { user_id: id }
    token = JwtService.encode(payload)

    validation_url = api_users_confirm_url(token: token)
    safe_email = email.parameterize(separator: "_")
    filename = "#{safe_email}.txt"

    File.write(
      Rails.root.join("tmp/#{filename}"),
      "Confirm your account: #{validation_url}"
    )
  end
end
