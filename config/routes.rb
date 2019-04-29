Scheduling::Application.routes.draw do

    # -------------------------------------------------

    # Tool routes
    constraints(Subdomain) do

        namespace :api do
            namespace :v1 do
                resources :invoices, only: [:index, :show] do
                    get :due, on: :collection
                    get :expected, on: :collection
                    get :payment_predictions, on: :collection
                    get :allocated, on: :collection
                end
                resources :projects, only: [:index, :show] do
                    member do
                        get :timings
                        get :tasks
                        get :payment_profiles
                    end
                end
                resources :teams, only: [:index, :show] do
                    member do
                        get :entries
                        get :timings
                    end
                end
                resources :clients, only: [:index, :show] do
                    member do
                        get :profit_and_loss
                    end
                end
            end
        end
        
        # Schedule api for JS calendar
        namespace :calendars do
            
            resources :entries do
                collection do 
                    get :entries_for_user
                end
            end
            resources :projects do
                collection do
                    get :recent
                end
            end
            resources :users
            resources :clients, only: [:index, :show]
        end
 
        # Track api for calendar
        namespace :team_api do
            resources :teams, only: [:show, :update, :create]
            resources :users, only: [:show, :update]
        end       
        
        # Track api for calendar
        namespace :track_api do
            resources :timings
            
            resources :projects do
                resources :tasks
            end
        end
        
        
        # Track namespace
        namespace :track do
            resources :timings do
                collection do
                    post :submit_time
                    get :submitted_time_report
                    post :shift_calendar
                end
            end
        end
        
        
        # Schedule namespace
        namespace :schedule do
            resources :entries do
                collection do 
                    get :lead_time
                end
            end
        end

        resources :entries, only: [:index]
        
        # quote namespace
        namespace :quote do
          resources :projects, :only => [:index] do
            
            collection do
              get :search
            end
            
            resources :quotes, :except => [:new, :edit] do
              
              member do
                get :edit_details
                put :update_details
                put :copy_from_previous
              end
              
              
              resources :quote_sections, :except => [:new, :edit, :index] do
                collection do
                  post :sort
                end
              end
              
              resources :quote_activities, :except => [:index] do
                collection do
                  post :sort
                end
              end
              
            end
          end
        end
        
        
        # invoice namespace
        namespace :invoice do
            
            resources :projects, :only => [:index] do
              
              resources :payment_profiles, :except => [:show] do
                
                member do
                    get :edit_service_types
                    put :update_service_types
                end
                
                collection do
                    get :add_rate_card_select
                    get :generate_from_schedule
                    post :generate_from_schedule_save
                end
                
              end

              resources :payment_profile_rollovers, only: [:edit, :update]
              
              resources :invoices do
                member do
                  get :change_status
                end
                
                  collection do
                      get :add_blank_item
                      get :add_payment_profile
                      get :add_tracked_time
                      post :insert_payment_profiles
                      post :insert_tracked_time
                  end
              end
              
              resources :invoice_usages
            end
        end

        resources :phases
        
        resources :projects do
          
          resources :project_comments, :except => [:new] do
            collection do
              get :preview
            end
            
            member do
              get :cancel
              get :reply
              post :submit_reply
            end
          end
          
            member do
                get :schedule
                get :track
                put :archive
                put :activate
                get :edit_percentage_complete
                put :update_percentage_complete
            end
            
            resources :tasks do
                member do
                    put :archive
                end
                collection do
                    get :cancel
                    post :sort
                    get :new_import_quote
                    post :import_quote
                end
            end
            
            resources :features do
                collection do
                    get :cancel
                end
            end
            
            resources :documents, :only => [:index, :new, :create, :show, :destroy] do
              
              collection do
                get :switch
                get :new_upload
                post :save_upload
              end
              
              resources :document_comments, :except => [:index, :new] do
                member do
                  get :cancel
                end
              end
            end
        end

        
        resources :clients do
            member do
                put :archive
                put :activate
            end
            collection do
                get :cancel
            end
            
            resources :client_rate_cards do
            end
        end


        resources :users do
            collection do
                get :edit_roles
                post :update_roles
            end
        end
        
        resources :teams do
            collection do
                get :cancel
            end
        end

        resources :team_users, only: [:create]
        delete :team_users, to: 'team_users#destroy'
        
        resources :account_settings do
            collection do
                get :confirm_remove
                put :change_plan
                get :payment_details
                get :statements
                get :statement
                put :enable_component
                put :disable_component
            end
        end
        
        
        resources :quote_default_sections, :except => [:index, :new, :edit] do
          collection do
            post :sort
          end
        end
        
        
        resources :settings do
          collection do
            get :personal
            get :quote
            get :invoice
            get :schedule
            get :issue_tracker
            get :inform_overdue_timesheet
          end
          
          member do
            put :update_hopscotch
            put :update_quote
            put :update_invoice
            put :update_schedule
            put :update_issue_tracker
            get :remove_logo
          end
        end
        
        resources :rate_cards
        
        resource :session, :only => [:new, :create, :destroy]

        resources :password_resets, :only => [:new, :create, :edit, :update]
        
        # oauth
        namespace :oauth do
            resources :drive_callbacks, :only => [] do
                collection do
                    get "google"
                    get "dropbox"
                end
            end
        end
        
        
        # reports namespace
        namespace :reports do
            resources :pages, :only => [:index] do
                collection do
                    get :select_project
                    post :submit_select_project
                    get :update_project
                end
            end
            
            resources :clients, :only => [] do
              member do
                  get :project_profit_and_loss
                  get :quote_project_profit_and_loss
              end
              
              collection do
                  get :profit_and_loss
                  get :quote_profit_and_loss
              end
            end
            
            resources :projects, :only => [] do
              collection do
                  get :overview
                  get :percentage_time_spent
                  get :project_utilisation
                  get :forecast
              end
              
              member do
                get :qa_stats
              end
            end
            
            resources :payment_profiles, :only => [] do
              collection do
                get :rollover
              end
            end
            
            resources :tasks, :only => [] do
              collection do
                get :no_estimates
              end
            end
            
            resources :invoices, :only => [] do
              collection do
                get :combined_pre_payments
                get :invoice_status
                get :payment_predictions
                get :deletions
                get :normalised_monthly
                get :allocation_breakdown
              end
            end
            
            get '/' => 'pages#index'
        end

        
        # Index
        get '/' => 'dashboards#index'
    end


    # Chargify callbacks
    namespace :chargify do
        
        resources :notifiers do
            collection do
                get 'confirmation'
                get 'confirmation_update'
            end
        end

        match '/webhooks/hook' => "webhooks#hook", :via => "post"
    end
    
    
    # oauth
    namespace :oauth do
        resources :drive_callbacks, :only => [:index]
    end
    
    # Front routes
    resources :accounts do
        collection do
            post "verify_suite"
        end
    end
    
    
    # Admin
    namespace :profile_admin do
        resources :accounts
        resources :users
        resources :projects 
        
        get '/' => 'accounts#index'
    end

    

    # Front pages
    get 'signup', :to => 'pages#signup', :as => 'pricing'
    get 'privacy', :to => 'pages#privacy', :as => 'privacy'
    get 'terms', :to => 'pages#terms', :as => 'terms'
    get 'time_tracking_tool', :to => 'pages#time_tracking_tool', :as => 'time_tracking_tool'
    get 'scheduling_tool', :to => 'pages#scheduling_tool', :as => 'scheduling_tool'
    get 'quote_tool', :to => 'pages#quote_tool', :as => 'quote_tool'
    get 'invoice_tool', :to => 'pages#invoice_tool', :as => 'invoice_tool'
    get 'schedule', :to => 'pages#scheudle'
    get 'thanks/:account_name', :to => 'pages#thanks', :as => 'thankyou'

    # Robots
    match '/robots.txt' => RobotsGenerator

    # index
    root :to => 'pages#index'

end
