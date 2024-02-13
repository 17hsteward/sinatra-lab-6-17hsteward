class TasksController < ApplicationController
  get '/tasks' do
    tasks = current_user.tasks.all
    if is_json_request?
      json tasks
    else
      erb :"tasks/index.html", locals: { tasks: tasks }
    end
  end

  get '/tasks/new' do
    erb :"tasks/new.html"
  end

  post '/tasks' do
    task = Task.new(description: params[:description], user: current_user)
    if task.save
      tasks = current_user.tasks.all
      if is_json_request?
        status 201
        json task
      else
        erb :"tasks/index.html", locals: { tasks: tasks }
      end
    else
      if is_json_request?
        status 400
        json_response = {errors: [task.errors.full_messages.join("; ")]}
        json json_response
      else
        flash.now[:errors] = task.errors.full_messages.join("; ")
        erb :"tasks/new.html"
      end
    end
  end

  get '/tasks/:id' do
    if Task.exists?(params[:id])
      task = Task.find(params[:id])
      if task.user != current_user
        status 404
        json ''
      else
        if is_json_request?
          json task
        else
          erb :"tasks/edit.html", locals: { task: task }
        end
      end
    else
      status 404
      json ''
    end
  end

  put '/tasks/:id' do
    task = Task.find(params[:id])
    task.description = params[:description]
    if task.save
      redirect "/"
    else
      flash.now[:errors] = task.errors.full_messages.join("; ")
      erb :"tasks/edit.html", locals: { task: task }
    end
  end

  delete '/tasks/:id' do
    task = Task.find(params[:id])
    task.destroy!
    redirect "/"
  end
end
