class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :group_memberships, dependent: :destroy
  has_many :joined_groups, through: :group_memberships, source: :group
  has_many :groups, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :goal_completions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one_attached :photo

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def display_name
    first_name.presence || username
  end

  def initials
    [first_name, last_name].compact_blank.map { |n| n[0] }.join.upcase.presence || username.to_s[0].to_s.upcase
  end
end
