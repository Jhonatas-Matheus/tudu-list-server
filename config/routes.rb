Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  #Rotas de task
  # get 'users/find_by_email', to: 'custom_user#find_by_email'
  post 'users/find_by_email', action: :find_by_email, controller: :custom_user
  post 'task', action: :addTask, controller: :task
  post 'task/add_user/', action: :addUserToTask, controller: :task
  delete 'task/:task_id', action: :deleteTask, controller: :task
  # delete 'task/:task_id/remove_user/:user_id', action: :removeUserOfTask , controller: :task
  delete 'task/:task_id', action: :leaveOfTask, controller: :task
  get 'task/:task_id', action: :showSpecificTask, controller: :task
  get 'task', action: :showAllTAskOfUser, controller: :task
  patch 'task/:task_id', action: :updateTask, controller: :task
  put 'task/:task_id', action: :changeTaskToDoneOrDo, controller: :task
  post 'task/subtask/:task_id', action: :create_subtask, controller: :task
  post 'task/subtask/', action: :changeSubtaskToDo, controller: :task
  #Rotas de comment
  post 'comment', action: :addComment, controller: :comment
  get 'comment/:task_id', action: :getCommentSpecificTask, controller: :comment
end
