class GoalCompletionsController < ApplicationController
  before_action :set_group

  def update_progress
    goal = @group.goal
    day = Integer(params[:day], exception: false)

    unless goal && day&.between?(0, Goal::CHALLENGE_DAYS - 1)
      render json: { success: false }, status: :unprocessable_entity and return
    end

    date = goal.day_date(day)
    if ActiveModel::Type::Boolean.new.cast(params[:completed])
      GoalCompletion.find_or_create_by(user: current_user, goal: goal, date: date)
    else
      GoalCompletion.where(user: current_user, goal: goal, date: date).destroy_all
    end

    render json: { success: true, completed: GoalCompletion.where(user: current_user, goal: goal).count }
  end

  private

  def set_group
    @group = current_user.joined_groups.find_by(id: params[:group_id])
    head :not_found unless @group
  end
end
