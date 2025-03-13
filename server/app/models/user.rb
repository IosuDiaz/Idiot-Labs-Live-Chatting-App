class User < ApplicationRecord
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
end
