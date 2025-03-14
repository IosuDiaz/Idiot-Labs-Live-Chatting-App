class Channel < ApplicationRecord
  belongs_to :creator, class_name: "User"

  has_many :messages, dependent: :destroy

  validates :name,
    presence: true,
    uniqueness: true,
    format: {
      with: /\A[\w-]+\z/,
      message: "just letters, numbers, scores and underscores allowed"
    }

  validates :description, length: { maximum: 500 }
end
