Rails.application.routes.draw do
  root 'dashboard#home'
  devise_for :admins
  devise_for :users

  resources :companies do
    resources :orders
  end
  
  resources :timesheets, module: "admin" do
    member do
      patch 'approve'
    end
  end
  resources :jobs, module: "admin" do
    member do
      patch 'clock_in'
    end
  end
  resources :shifts, path: "admin/shifts", module: "admin" do
    collection do
      patch 'clock_out_all'
    end
    member do
      patch 'clock_out'
    end
  end
  resources :shifts, module: "employee" do
    member do
      patch 'clock_out'
    end
  end
  resources :employees, module: "admin"
  get 'orders' => 'orders#all'
  get 'archived_jobs' => 'jobs#archived'
  
  resources :users do
    member do
      patch :grant_editing
    end
  end

  get  'timeclock', to: 'employee/dashboard#employee_view'
  get  'home', to: 'employee/dashboard#home'
  
  resources :timesheets, path: "employee/timesheets", module: "employee"
  resources :jobs, path: "employee/jobs", module: "employee"
    

  resources :admins
  resources :users

  
  
  
  
  
  
  # devise_for :users, controllers: {
  #       sessions: 'users/sessions'
  #     }
  

  get  'dashboard' => 'dashboard#company_view'
  
  get  'agency_access' => 'dashboard#agency_view'
  
  # resources :timesheets do
  #   member do
  #     patch 'approve'
  #   end
  # end  
  
  
  
  # resources :orders
  
  # resources :jobs do
  #   resources :shifts do
  #     member do
  #       patch 'clock_out'
  #     end
  #   end
  # end

  # resources :companies do
  #   resources :orders do
  #     resources :jobs
  #   end
  # end
  # resources :employees do
  #   resources :shifts do
  #     member do
  #       patch 'clock_out'
  #     end
  #   end
  # end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  

  # Example of regular route:


  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
