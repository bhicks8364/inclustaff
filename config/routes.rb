class SubdomainConstraint
  def self.matches?(request)
    subdomains = %w{ www admin public }
    request.subdomain.present? && !subdomains.include?(request.subdomain)
  end
end
Rails.application.routes.draw do
  root 'dashboard#home'
  get 'features' => 'dashboard#features'
  
  resources :agencies
  resources :inquiries
  
  constraints SubdomainConstraint do
    get  'sign_in' => 'dashboard#sign_in_page'  
    get 'tags' => 'admin/dashboard#all_tags'
    get 'tags/:tag', to: 'admin/dashboard#tag', as: :tag
    get 'paid_invoices', to: 'charts#paid_invoices'
    get 'account_managers_ranking', to: 'charts#account_managers_ranking'
    get 'recruiter_ranking', to: 'charts#recruiter_ranking'
    get 'order_fill_time', to: 'charts#order_fill_time'
    devise_for :admins, controllers: {registrations: 'admins/registrations'}
    devise_for :users, controllers: {registrations: 'users/registrations'}
    
    resources :admins do
      member do
        post :mention
        post :follow
        
      end
    end
    resources :users do
      collection do
        post :import
      end
      member do
        patch :grant_editing
      end
    end
    
    # ADMIN ----> /admin
    namespace :admin do
      get  'agency_access' => 'dashboard#agency_view'
      get  'payroll' => 'dashboard#payroll'
      get  'dashboard' => 'dashboard#home'
      get  'owner' => 'dashboard#owner'
      get  'recruiter' => 'dashboard#recruiter'
      resources :companies do
        resources :invoices
        resources :timesheets
        resources :orders
        collection do
          post 'import'
        end
        
      end
      resources :invoices do
        member do
          patch 'mark_as_paid'
        end
      end
      
      resources :timesheets do
        collection do
          get 'past'
        end
        
      end
      resources :employees do
        collection do
          get 'autocomplete'
        end
        resources :jobs
        resources :skills
        resources :work_histories
      end
      
      resources :orders do
        resources :skills
        resources :jobs
      end

      resources :jobs, shallow: true do
        resources :timesheets, shallow: true do
          collection do
            get 'past'
          end
          member do
            patch 'approve'
          end
        end
        member do
          patch 'clock_in'
          patch 'clock_out'
        end
      end
      
      
      resources :shifts do
        member do
          patch 'clock_out'
          patch 'break_start'
          patch 'break_end'
          patch 'remove_breaks'
        end
      end
      
    end
    # END ADMIN
    # EMPLOYEE ---> /employee
    namespace :employee do
      get  'timeclock', to: 'dashboard#employee_view'
      get  'home', to: 'dashboard#home'
      resources :orders do
        collection do
          get 'import'
        end
        member do
          patch :apply
        end
      end
      resources :jobs do
        member do
          patch 'clock_in'
          patch 'clock_out'
        end
      end
      resources :timesheets
      resources :shifts do
        member do
          patch 'clock_out'
          patch 'break_start'
          patch 'break_end'
        end
      end
    end
    resources :events
    resources :work_histories
    resources :skills do
      collection do
        get 'autocomplete'
        post 'import'
        post 'update_all'
      end
    end
    
    get 'orders' => 'orders#all'
    get 'archived_jobs' => 'jobs#archived'
    
    
    
    
    
    
  end
  # END SUBDOMAIN CONTRAINT

  

  
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
