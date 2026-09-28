class GoalsController < ApplicationController
  before_action :set_group
  before_action :set_goal, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to group_path(@group)
  end

  def show
    redirect_to group_path(@group)
  end

  def new
    if @group.goal
      redirect_to edit_group_goal_path(@group, @group.goal) and return
    end
    @goal = @group.goals.build(start_date: Date.current)
  end

  def create
    @goal = @group.goals.build(goal_params.merge(user: current_user))

    if @goal.save
      redirect_to group_path(@group), notice: "Challenge set. Day one starts #{@goal.start_date.strftime('%-d %B')}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @goal.update(goal_params)
      redirect_to group_path(@group), notice: "Challenge updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    redirect_to group_path(@group), notice: "Challenge removed."
  end

  private

  def set_group
    @group = current_user.joined_groups.find_by(id: params[:group_id])
    redirect_to groups_path, alert: "Group not found." unless @group
  end

  def set_goal
    @goal = @group.goals.find_by(id: params[:id])
    redirect_to group_path(@group), alert: "Challenge not found." unless @goal
  end

  def goal_params
    params.require(:goal).permit(:name, :start_date, :reason)
  end
end
