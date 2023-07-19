class TaskController < ApplicationController
    before_action :authenticate_user!
    def addTask
        task = Task.new(title: params[:title], description: params[:description], deadline: params[:deadline], status: params[:status], user_ids: params[:user_ids])
        task.user_ids << current_user.id
        task.owner = current_user.id
        if task.save
            render json: task, status: :ok            
        else
            render json: {message: "Something wrong, try again latter"}, status: :unprocessable_entity
        end
    end

    def addUserToTask
        task = Task.find(params[:task_id])
        user = User.find(params[:user_id])
        if task.owner.to_s.strip != current_user.id.to_s.strip
            return render json: {message: "You dont have permission for modify task"}, status: :unauthorized 
        end
        if task.user_ids.include?(user.id)
            render json: {message: "User already associated with the task" }, status: :conflict
        else
            task.user_ids << user.id
            task.save
            render json: task, status: :created
        end
    end

    def updateTask
        begin
        task = Task.find(params[:task_id])
        request_params = {
            title: params[:title], 
            description: params[:description], 
            deadline: params[:deadline], 
            status: params[:status]
        }.compact
        task.update(request_params)
        render json: task, status: :ok
        rescue => exception
            render json: {message: "Task not found"}, status: :not_found
        end
    end
    def removeUserOfTask
        task = Task.find(params[:task_id])
        user = User.find(params[:user_id])
        if task.owner.to_s.strip != current_user.id.to_s.strip
            return render json: {message: "You dont have permission for modify task"}, status: :unauthorized 
        end
        if task.user_ids.include?(user.id)
            task.user_ids.delete(user.id)
            task.save
            render json: {message: "User successfully removed from the task"}, status: :ok
        else
            render json: { message: "User is not associated with the task"}, status: :not_found
        end
    end

    def leaveOfTask
        task = Task.find(params[:task_id])
        if task.user_ids.include?(current_user.id)
            task.user_ids.delete(current_user.id)
            task.save
            render json: {message: "User leave from the task"}, status: :ok
        else
            render json: {message: "User is not associated with the task"}, status: :not_found
        end
    end

    def showSpecificTask
        begin
            task = Task.find(params[:task_id])
            if task.present?
                task[:members] = self.handleUserRelation(task.user_ids)
                render json: task, status: :ok
            else
                render json: {message: "Task not found"}, status: :not_found
            end
        rescue => exception
                render json: {message: "Task not found"}, status: :not_found
        end
    end

    private

    def handleUserRelation(usersArray)
        users = []
        usersArray.each do |user_id|
            user = User.find(user_id)
            userInfo = {email: user.email, id: user.id}
            users << userInfo
        return users
        end
    end
    

end
