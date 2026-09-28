class CommentsController < ApplicationController
  before_action :set_group

  def create
    @comment = @group.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to group_path(@group, anchor: "comments")
    else
      redirect_to group_path(@group, anchor: "comments"), alert: "Write something before posting."
    end
  end

  def update
    comment = @group.comments.find(params[:id])
    comment.increment!(:likes)
    render json: { likes: comment.likes }
  end

  def destroy
    comment = @group.comments.find(params[:id])
    if comment.user == current_user
      comment.destroy
      redirect_to group_path(@group, anchor: "comments"), notice: "Comment deleted."
    else
      redirect_to group_path(@group, anchor: "comments"), alert: "You can only delete your own comments."
    end
  end

  private

  def set_group
    @group = current_user.joined_groups.find_by(id: params[:group_id])
    head :not_found unless @group
  end

  def comment_params
    params.require(:comment).permit(:message)
  end
end
