class TaskController < ApplicationController
    before_action :authenticate_user!
    def addTask
        task = Task.new(title: params[:title], description: params[:description], deadline: params[:deadline], priority: rand(1..3), status: params[:status], user_ids: params[:user_ids], categories: params[:categories])
        task.user_ids << current_user.id
        task.owner = current_user.id
        subtasks_params = params[:subtasks] || [] # Obtém os parâmetros das subtasks do array subtasks dentro de params
        puts(subtasks_params)
        # Adiciona as subtasks manualmente à tarefa
        subtasks_params.each do |subtask_params|
            task.subtasks << { "title" => subtask_params[:title], "status" => subtask_params[:status] }
        end
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

    def changeSubtaskToDo
        puts(params[:task_id])
        puts(params[:subtask_id])
        task = Task.find(params[:task_id])
        subtask = task.subtasks.find { |st| st['subtask_id'].to_s == params[:subtask_id] }
        if subtask
            if subtask['status'] == 1
                subtask['status'] = 0
            else
                subtask['status'] = 1
            end
          task.save
          render json: { message: 'Subtask marcada como "done" com sucesso!' }
        else
          render json: { error: 'Subtask não encontrada.' }, status: :not_found
        end
    end

    def updateTask
        begin
        task = Task.find(params[:task_id])
        request_params = {
            title: params[:title], 
            description: params[:description], 
            deadline: params[:deadline], 
            status: params[:status],
        }.compact
        task.update(request_params)
        render json: task, status: :ok
        rescue => exception
            render json: {message: "Task not found"}, status: :not_found
        end
    end

    def create_subtask
        task = Task.find(params[:task_id])

        new_subtask = {
          subtask_id: SecureRandom.uuid,
          title: params[:title],
          status: 0
        }
        task.subtasks << new_subtask
    
        if task.save
          render json: { message: 'Subtask criada com sucesso!', subtask: new_subtask }
        else
          render json: { error: 'Não foi possível criar a subtask.' }, status: :unprocessable_entity
        end
    end

    def deleteTask
        task = Task.find(params[:task_id])
        task.delete()
        render json: {message: "Task deleted"}, status: :not_found
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

    def showAllTAskOfUser
        currentUser = User.find(current_user.id)
        puts(currentUser)
        tasks = Task.collection.aggregate([
            {'$match'=>{
                'user_ids'=> BSON::ObjectId(current_user.id)
            }},
            {
                '$lookup' =>{
                    from: 'users',
                    localField: 'user_ids',
                    foreignField: '_id',
                    as: 'members'
            }},
            {
                "$lookup": {
                  "from": "comments",
                  "localField": "_id",
                  "foreignField": "task_id",
                  "as": "comments"
                }
              },
              {
                "$lookup": {
                  "from": "users",
                  "localField": "comments.user_id",
                  "foreignField": "_id",
                  "as": "user"
                }
              },
            {
                '$project' => {
                    '_id': 1,
                    'files': 1,
                    'subtasks': 1,
                    'categories': 1,
                    'title': 1,
                    'description': 1,
                    'deadline': 1,
                    'priority': 1,
                    'status': 1,
                    'owner': 1,
                    'updated_at':1,
                    'created_at':1,
                    'members.allow_password_change':1,
                    'members.email':1,
                    'members.first_name':1,
                    'members.last_name':1,
                    'members.firebaseId':1,
                    'members.locker_locked_at':1,
                    'members.locker_locking_name':1,
                    'members.locking_name':1,
                    'members.provider':1,
                    'members.reset_password_redirect_url':1,
                    'members.uid':1,
                    'members._id':1,
                    'comments':{
                        '$map': {
                            'input': '$comments',
                            'as': 'comment',
                            'in': {
                              'created_at': '$$comment.created_at',
                              'user': {
                                'first_name': '$$comment.user.first_name'
                              }
                            }
                          }
                        
                    }
                    
                    
                    
            }},
           
        ])

        render json: tasks, status: :ok
    end

    def showSpecificTask
        currentTask = Task.find(params[:task_id])
        task = Task.collection.aggregate([
            {
                '$match' =>{
                    '_id': BSON::ObjectId(params[:task_id])
                }
            },
            {
                '$lookup' =>{
                    'from': 'users',
                    'localField': 'user_ids',
                    'foreignField': '_id',
                    'as': 'members'
            }},
            {
                "$lookup": {
                  "from": "comments",
                  "localField": "_id",
                  "foreignField": "task_id",
                  "as": "comments"
                }
              },
            #   {
            #     "$unwind": "$comments"
            #   },
              {
                "$lookup": {
                  "from": "users",
                  "localField": "comments.user_id",
                  "foreignField": "_id",
                  "as": "user"
                }
              },
            #   {
            #     "$unwind": "$user"
            #   },
            # {          
            #     "$group": {
            #         "_id": "$_id",
            #         "files": { "$first": "$files" },
            #         "subtasks": { "$first": "$subtasks" },
            #         "categories": { "$first": "$categories" },
            #         "title": { "$first": "$title" },
            #         "description": { "$first": "$description" },
            #         "deadline": { "$first": "$deadline" },
            #         "priority": { "$first": "$priority" },
            #         "status": { "$first": "$status" },
            #         "owner": { "$first": "$owner" },
            #         "updated_at": { "$first": "$updated_at" },
            #         "created_at": { "$first": "$created_at" },
            #         "members": { "$first": "$members" },
            #         "comments": {
            #         "$push": {
            #             "content": "$comments.content",
            #             "created_at": "$comments.created_at",
            #             "user": {
            #             "first_name": "$user.first_name",
            #             "last_name": "$user.last_name",
            #             "id": "$user._id"
            #             }
            #     }
            #     }
            # }},
            {
                '$project' => {
                    '_id': 1,
                    'files': 1,
                    'subtasks': 1,
                    'categories': 1,
                    'title': 1,
                    'description': 1,
                    'deadline': 1,
                    'priority': 1,
                    'status': 1,
                    'owner': 1,
                    'updated_at':1,
                    'created_at':1,
                    'members.allow_password_change':1,
                    'members.email':1,
                    'members.first_name':1,
                    'members.last_name':1,
                    'members.firebaseId':1,
                    'members.locker_locked_at':1,
                    'members.locker_locking_name':1,
                    'members.locking_name':1,
                    'members.provider':1,
                    'members.reset_password_redirect_url':1,
                    'members.uid':1,
                    'members._id':1,
                    'comments':[]
                    # 'comments':1                    
            }},
           
        ])
        return render json: task, status: :ok
    end

    def changeTaskToDoneOrDo
        task = Task.find(params[:task_id])
        if task.status == 0
            task.update(status: 1)
            task.subtasks.each do |subtask|
                subtask['status'] = 1
            end
        else
            task.update(status: 0)
            task.subtasks.each do |subtask|
                subtask['status'] = 0
            end
        end
        task.save
        render json: {message: 'Tarefa concluída'}
    end
    private

    def handleUserRelation(usersArray)
        users = []
        usersArray.each do |user_id|
            user = User.find(user_id)
            userInfo = {email: user.email, id: user._id}
            users << userInfo
        return users
        end
    end
    

end
