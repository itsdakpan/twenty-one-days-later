class GoalCompletion < ApplicationRecord
  belongs_to :user
  belongs_to :goal

  validates :date, presence: true, uniqueness: { scope: [:user_id, :goal_id] }
end
