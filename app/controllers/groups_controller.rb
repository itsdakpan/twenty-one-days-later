class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :destroy]

  def index
    @groups = current_user.joined_groups.includes(:goals, members: { photo_attachment: :blob })
                          .sort_by { |group| group.goal&.start_date || Date.new(3000, 1, 1) }
  end

  def new
    @group = Group.new
    @usernames = User.where.not(id: current_user.id).order(:username).pluck(:username)
  end

  def create
    @group = Group.new(name: group_params[:name], user: current_user)
    if @group.save
      usernames = Array(group_params[:user_usernames]).reject(&:blank?)
      User.where(username: usernames).find_each do |user|
        @group.group_memberships.find_or_create_by(user: user)
      end
      @group.group_memberships.find_or_create_by(user: current_user)

      redirect_to new_group_goal_path(@group), notice: "Group created. Now set the challenge."
    else
      @usernames = User.where.not(id: current_user.id).order(:username).pluck(:username)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @goal = @group.goal
    @members = @group.members.includes(photo_attachment: :blob)
    @completed_days = completed_days_by_member
    @comments = @group.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new
  end

  def destroy
    unless @group.owned_by?(current_user)
      redirect_to groups_path, alert: "Only the person who created this group can delete it." and return
    end

    @group.destroy
    redirect_to groups_path, notice: "Group deleted."
  end

  private

  def set_group
    @group = current_user.joined_groups.find_by(id: params[:id])
    redirect_to groups_path, alert: "Group not found." unless @group
  end

  # { user_id => [0, 1, 4, ...] } where each number is a day index from 0 to 20
  def completed_days_by_member
    return {} unless @goal

    GoalCompletion.where(goal: @goal).each_with_object(Hash.new { |h, k| h[k] = [] }) do |completion, result|
      index = (completion.date - @goal.start_date).to_i
      result[completion.user_id] << index if index.between?(0, Goal::CHALLENGE_DAYS - 1)
    end
  end

  def group_params
    params.require(:group).permit(:name, user_usernames: [])
  end
end
