Rails.application.routes.draw do
  resources :tasks do
    member do
      get 'sign_up' => 'classified_advertisement/tasks#sign_up_form'
      put 'sign_up' => 'classified_advertisement/tasks#sign_up'
      get 'change_signing' => 'classified_advertisement/tasks#sign_up_form'
      delete 'sign_out' => 'classified_advertisement/tasks#sign_out'
    end
  end
  
  resources :stories, only: [:create, :show, :edit, :update, :destroy] do
    resources :tasks, only: [:index, :new] do
      collection do
        get 'calendar' => 'classified_advertisement/tasks#calendar'
        get 'events' => 'classified_advertisement/tasks#events'
      end
    end
  end
end
