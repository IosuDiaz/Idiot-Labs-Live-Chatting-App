class Channel < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates :name,
    presence: true,
    uniqueness: true,
    format: {
      with: /\A[\w-]+\z/,
      message: "solo permite letras, números, guiones y underscores"
    }

  validates :description, length: { maximum: 500 }
end
