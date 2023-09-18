class CommentController < ApplicationController

    def addComment
        task = Task.find(params[:task_id])
        user = User.find(current_user.id)
        comment = Comment.new(content: params[:content], task: task, user: user)
        if comment.save
            return render json: comment, status: :created
        else
            return render json: {message: "Something wrong"}, status: unprocessable_entity
        end
    end

    def getCommentSpecificTask
        task = Task.find(params[:task_id])
        comments = Comment.collection.aggregate([
            {
                '$match' => {
                  'task_id' => BSON::ObjectId(task.id)
                }
              }, {
                '$lookup' => {
                  'from' => 'users',
                  'localField' => 'user_id',
                  'foreignField' => '_id',
                  'as' => 'user'
                }
              }, {
                '$lookup' => {
                  'from' => 'tasks',
                  'localField' => 'task_id',
                  'foreignField' => '_id',
                  'as' => 'task'
                }
              }, {
                '$project' => {
                  'content' => 1,
                  'created_at' => 1,
                  'user' => {
                    'first_name' => 1,
                    'last_name' => 1,
                    '_id' => 1
                  }
                }
              }
        ])
        return render json: comments, status: :ok
    end
end
