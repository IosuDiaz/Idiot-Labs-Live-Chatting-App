class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_secure_password

  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "formato inválido" }

  validates :nickname,
    presence: true,
    uniqueness: true,
    length: { in: 3..20 },
    format: { with: /\A[a-zA-Z0-9_]+\z/, message: "solo letras, números y _" }

  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  after_create :generate_validation_link

  private

  def generate_validation_link
    payload = { user_id: id, exp: 24.hours.from_now.to_i }
    token = JwtService.encode(payload)

    validation_url = api_users_confirm_url(token: token)
    safe_email = email.parameterize(separator: "_")
    filename = "#{safe_email}.txt"

    File.write(
      Rails.root.join("tmp/#{filename}"),
      "Valida tu cuenta: #{validation_url}"
    )
  end
end
