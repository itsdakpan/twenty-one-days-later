class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :message, presence: true, length: { maximum: 500 }
end
