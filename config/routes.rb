class SubdomainConstraint
  def self.matches?(request)
    subdomains = %w{ www admin public }
    request.subdomain.present? && !subdomains.include?(request.subdomain)
  end
end
Rails.application.routes.draw do
  
  root 'dashboard#home'
  get 'features' => 'dashboard#features'
  get 'contact' => 'dashboard#contact'
  get 'about' => 'dashboard#about'
  
  resources :agencies
  resources :inquiries
  
  constraints SubdomainConstraint do
    get  'sign_in' => 'dashboard#sign_in_page'  
    # TAGS
    get 'tags' => 'admin/dashboard#all_tags'
    get 'tags/:tag', to: 'admin/dashboard#tag', as: :tag
    # CHARTS
    get 'paid_invoices', to: 'charts#paid_invoices'
    get 'companies_balance', to: 'charts#companies_balance'
    get 'account_managers_ranking', to: 'charts#account_managers_ranking'
    get 'recruiter_ranking', to: 'charts#recruiter_ranking'
    get 'order_fill_time', to: 'charts#order_fill_time'
    get 'current_weeks_billing', to: 'charts#current_weeks_billing'
    devise_for :admins, controllers: {registrations: 'admins/registrations'}
    devise_for :company_admins, controllers: {registrations: 'company_admins/registrations'}
    devise_for :users, controllers: {registrations: 'users/registrations'}
    resources :comments
    resources :admins do
      member do
        post :mention
        post :follow
        
      end
    end
    resources :company_admins do
      member do
        post :mention
        post :follow
        
      end
    end
    resources :users do
      collection do
        post :import
        get :dns_list
        
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
      get  'account_manager' => 'dashboard#account_manager'
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
        resources :comments
        collection do
          get 'past'
        end
        
      end
      resources :employees do
        collection do
          get 'autocomplete'
          post 'import'
        end
        
        resources :skills
        resources :work_histories
      end
      
      resources :orders do
        resources :skills
        resources :jobs do
          collection do
            get 'inactive'
          end
        end
      end

      resources :jobs do
        collection do
          get 'inactive'
        end
        resources :comments
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
    
    # COMPANY_ADMIN ---> /company
    namespace :company do
      get  'dashboard' => 'dashboard#home'
      get 'timeclock' => 'dashboard#timeclock'

      get 'admins' => 'dashboard#admins'
      get 'admin/:id' => 'dashboard#admin', as: :admin_profile
      resources :orders
      resources :jobs do
        member do
          post 'verify_code'
          patch 'clock_in'
          patch 'clock_out'
        end
      end
      resources :timesheets do
        member do
          patch 'approve'
        end
        resources :comments
      end
      resources :invoices
      resources :shifts do 
        member do
          patch 'clock_out'
          patch 'break_start'
          patch 'break_end'
          patch 'remove_breaks'
        end
      end
    end
    # END COMPANY_ADMIN
    
    # EMPLOYEE ---> /employee
    namespace :employee do
      get  'timeclock', to: 'dashboard#timeclock'
      get  'home', to: 'dashboard#home'
      get  'job_board', to: 'dashboard#jobs'
      get  'profile', to: 'dashboard#profile'
      resources :work_histories
      resources :orders do
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
   # END EMPLOYEE
    
    
    
    resources :comments 
    
    resources :events
    resources :work_histories
    resources :skills do
      collection do
        get 'autocomplete'
        post 'import'
        post 'update_all'
      end
    end
    get 'comment_search' => 'comments#search'
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
