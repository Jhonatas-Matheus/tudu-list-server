Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  post 'task', action: :addTask, controller: :task
  post 'task/add_user/', action: :addUserToTask, controller: :task
  delete 'task/:task_id/remove_user/:user_id', action: :removeUserOfTask , controller: :task
  delete 'task/:task_id', action: :leaveOfTask, controller: :task
  get 'task/:task_id', action: :showSpecificTask, controller: :task
  get 'task', action: :showAllTAskOfUser, controller: :task
  patch 'task/:task_id', action: :updateTask, controller: :task
end
