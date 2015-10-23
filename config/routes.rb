Rails.application.routes.draw do
  resources :tasks do
    member do
      get 'sign_up' => 'classified_advertisement/tasks#sign_up_form'
      put 'sign_up' => 'classified_advertisement/tasks#sign_up'
      get 'change_signing' => 'classified_advertisement/tasks#sign_up_form'
      delete 'sign_out' => 'classified_advertisement/tasks#sign_out'
    end
  end
end
