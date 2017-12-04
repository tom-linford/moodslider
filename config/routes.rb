Rails.application.routes.draw do
  root 'welcome#moodslider'
  get 'upload', to: 'welcome#upload'
  post 'get_file' => 'welcome#get_file'
  get 'update' => 'welcome#update'
  post 'update' => 'welcome#update'
end
