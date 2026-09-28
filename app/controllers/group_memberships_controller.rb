class GroupMembershipsController < ApplicationController
  before_action :set_group

  def create
    if @group.members.include?(current_user)
      redirect_to group_path(@group), alert: "You're already in this group."
    elsif GroupMembership.create(user: current_user, group: @group).persisted?
      redirect_to group_path(@group), notice: "You joined #{@group.name}."
    else
      redirect_to groups_path, alert: "Could not join the group."
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end
end
