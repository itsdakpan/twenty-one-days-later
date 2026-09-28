class Goal < ApplicationRecord
  CHALLENGE_DAYS = 21

  belongs_to :user
  belongs_to :group
  has_many :goal_completions, dependent: :destroy
  validates :name, presence: true
  validates :reason, presence: true
  validates :start_date, presence: true

  before_save :set_end_date

  def day_date(index)
    start_date + index.days
  end

  def status
    today = Date.current
    if today < start_date
      :upcoming
    elsif today <= end_date
      :active
    else
      :finished
    end
  end

  def days_until_start
    (start_date - Date.current).to_i
  end

  def days_left
    (end_date - Date.current).to_i + 1
  end

  def current_day
    ((Date.current - start_date).to_i + 1).clamp(0, CHALLENGE_DAYS)
  end

  private

  # The challenge runs for 21 days, so the last day is start_date + 20.
  def set_end_date
    self.end_date = start_date + (CHALLENGE_DAYS - 1).days if start_date
  end
end
