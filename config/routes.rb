require 'robots_generator'

BootstrapStarter::Application.routes.draw do

  # user robots generator to avoid non-production sites from being indexed
  match '/robots.txt' => RobotsGenerator

  # upload images through tinymce wysiwyg
  post '/tinymce_assets' => 'tinymce_assets#create'

  devise_for :users, skip: [:sessions, :passwords, :registrations, :confirmations], :path_names => {:sign_in => 'login', :sign_out => 'logout'}, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		# devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'},
		# 									 :controllers => {:omniauth_callbacks => "users/omniauth_callbacks"}


    get 'omniauth/:provider' => 'omniauth#localized', as: :localized_omniauth
    devise_for :users, skip: :omniauth_callbacks, :path_names => {:sign_in => 'login', :sign_out => 'logout'}, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', passwords: 'users/passwords'}


    match '/admin', :to => 'admin#index', :as => :admin, :via => :get
    match '/admin/download_api_requests', :to => 'admin#download_api_requests', :as => :admin_download_api_requests, :via => :get, :defaults => { :format => 'csv' }
    match '/admin/download_download_requests', :to => 'admin#download_download_requests', :as => :admin_download_download_requests, :via => :get, :defaults => { :format => 'csv' }
    namespace :admin do
      resources :categories
      resources :shapesets
      resources :page_contents
      resources :users
      resources :api_versions, :except => [:show] do
        resources :api_methods, :except => [:index]
      end
      resources :help_sections, :except => [:show]
      resources :help_pages
    end

    resources :datasets, path: :manage_datasets do
      resources :groups, :except => [:show] do
        member do
          post 'group_questions', :defaults => { :format => 'json' }
        end
      end
      resources :weights, :except => [:show]
      resources :questions, :only => [:index, :show, :edit, :update] do
        collection do
          get 'mass_changes'
          post 'mass_changes'
          post 'load_mass_changes_questions'
          post 'load_mass_changes_answers'
        end
      end
      member do
        get 'explore'
        get 'warnings'
        get 'mass_changes_questions'
        post 'mass_changes_questions'
        get 'mass_changes_answers'
        post 'mass_changes_answers'
        get 'mass_changes_questions_type'
        post 'mass_changes_questions_type'
        get 'mappable'
        get 'mappable_form'
        post 'mappable_form'
        get 'mappable_form_edit'
        post 'mappable_form_edit'
        delete 'remove_mapping'
        post 'question_answers', :defaults => { :format => 'json' }
        post 'add_highlight'
        post 'remove_highlight'
        get 'highlights'
        post 'highlights'
        post 'home_page_highlight'
        get 'download_data'
        post 'generate_download_files', :defaults => { :format => 'json' }
        post 'generate_download_file_status', :defaults => { :format => 'json' }
        get 'sort'
        post 'sort'
      end
    end

    resources :time_series, path: :manage_time_series do
      resources :time_series_questions, :path => 'questions', :as => 'questions' do
        collection do
          get 'mass_changes'
          post 'mass_changes'
          post 'load_mass_changes_questions'
          post 'load_mass_changes_answers'
        end
      end
      resources :time_series_groups, :except => [:show] do
        member do
          post 'group_questions', :defaults => { :format => 'json' }
        end
      end
      resources :time_series_weights, :except => [:show], :path => 'weights', :as => 'weights'
      member do
        get 'explore'
        get 'automatically_assign_questions'
        post 'add_highlight'
        post 'remove_highlight'
        get 'highlights'
        post 'highlights'
        post 'home_page_highlight'
        get 'sort'
        post 'sort'
        get 'mass_changes_answers'
        post 'mass_changes_answers'
      end
    end

    # api
    match '/api', to: 'api#index', as: :api, via: :get
    namespace :api do
      ### v1
      match '/v1', to: 'v1#index', as: :v1, via: :get
      match '/v1/documentation(/:method)', to: 'v1#documentation', as: :v1_documentation, via: :get
      match '/v1/dataset_catalog', to: 'v1#dataset_catalog', as: :v1_dataset_catalog, via: :get, :defaults => { :format => 'json' }
      match '/v1/dataset', to: 'v1#dataset', as: :v1_dataset, via: :get, :defaults => { :format => 'json' }
      match '/v1/dataset_codebook', to: 'v1#dataset_codebook', as: :v1_dataset_codebook, via: :get, :defaults => { :format => 'json' }
      match '/v1/dataset_analysis', to: 'v1#dataset_analysis', as: :v1_dataset_analysis, via: :get, :defaults => { :format => 'json' }
      match '/v1/time_series_catalog', to: 'v1#time_series_catalog', as: :v1_time_series_catalog, via: :get, :defaults => { :format => 'json' }
      match '/v1/time_series', to: 'v1#time_series', as: :v1_time_series, via: :get, :defaults => { :format => 'json' }
      match '/v1/time_series_codebook', to: 'v1#time_series_codebook', as: :v1_time_series_codebook, via: :get, :defaults => { :format => 'json' }
      match '/v1/time_series_analysis', to: 'v1#time_series_analysis', as: :v1_time_series_analysis, via: :get, :defaults => { :format => 'json' }
      ### v2
      match '/v2', to: 'v2#index', as: :v2, via: :get
      match '/v2/documentation(/:method)', to: 'v2#documentation', as: :v2_documentation, via: :get
      match '/v2/dataset_catalog', to: 'v2#dataset_catalog', as: :v2_dataset_catalog, via: :get, :defaults => { :format => 'json' }
      match '/v2/dataset', to: 'v2#dataset', as: :v2_dataset, via: :get, :defaults => { :format => 'json' }
      match '/v2/dataset_question_data', to: 'v2#dataset_question_data', as: :v2_dataset_question_data, via: :get, :defaults => { :format => 'json' }
      match '/v2/dataset_codebook', to: 'v2#dataset_codebook', as: :v2_dataset_codebook, via: :get, :defaults => { :format => 'json' }
      match '/v2/dataset_analysis', to: 'v2#dataset_analysis', as: :v2_dataset_analysis, via: :get, :defaults => { :format => 'json' }
      match '/v2/time_series_catalog', to: 'v2#time_series_catalog', as: :v2_time_series_catalog, via: :get, :defaults => { :format => 'json' }
      match '/v2/time_series', to: 'v2#time_series', as: :v2_time_series, via: :get, :defaults => { :format => 'json' }
      match '/v2/time_series_codebook', to: 'v2#time_series_codebook', as: :v2_time_series_codebook, via: :get, :defaults => { :format => 'json' }
      match '/v2/time_series_analysis', to: 'v2#time_series_analysis', as: :v2_time_series_analysis, via: :get, :defaults => { :format => 'json' }
      ### v3
      match '/v3', to: 'v3#index', as: :v3, via: :get
      match '/v3/documentation(/:method)', to: 'v3#documentation', as: :v3_documentation, via: :get
      match '/v3/dataset_catalog', to: 'v3#dataset_catalog', as: :v3_dataset_catalog, via: :get, :defaults => { :format => 'json' }
      match '/v3/dataset', to: 'v3#dataset', as: :v3_dataset, via: :get, :defaults => { :format => 'json' }
      match '/v3/dataset_question_data', to: 'v3#dataset_question_data', as: :v3_dataset_question_data, via: :get, :defaults => { :format => 'json' }
      match '/v3/dataset_codebook', to: 'v3#dataset_codebook', as: :v3_dataset_codebook, via: :get, :defaults => { :format => 'json' }
      match '/v3/dataset_analysis', to: 'v3#dataset_analysis', as: :v3_dataset_analysis, via: :get, :defaults => { :format => 'json' }
      match '/v3/time_series_catalog', to: 'v3#time_series_catalog', as: :v3_time_series_catalog, via: :get, :defaults => { :format => 'json' }
      match '/v3/time_series', to: 'v3#time_series', as: :v3_time_series, via: :get, :defaults => { :format => 'json' }
      match '/v3/time_series_codebook', to: 'v3#time_series_codebook', as: :v3_time_series_codebook, via: :get, :defaults => { :format => 'json' }
      match '/v3/time_series_analysis', to: 'v3#time_series_analysis', as: :v3_time_series_analysis, via: :get, :defaults => { :format => 'json' }
    end

    # embed pages
    match '/embed', to: 'embed#index', as: :embed, via: :get
    namespace :embed do
      match '/v1/:id', to: 'v1#index', as: :v1, via: :get
      match '/v2/:id', to: 'v2#index', as: :v2, via: :get
      match '/v3/:id', to: 'v3#index', as: :v3, via: :get
    end

    # highlights
#    match '/highlights', to: 'highlights#index', as: :highlights, via: :get
    match '/highlights/get_description', to: 'highlights#get_description', as: :highlights_get_description, via: :post, :defaults => { :format => 'json' }
    match '/highlights/edit_description', to: 'highlights#edit_description', as: :highlights_edit_description, via: [:get, :post], :defaults => { :format => 'json' }

    # root pages
    match '/contact', :to => 'root#contact', :as => :contact, :via => [:get, :post]
    match '/download/:id', :to => 'root#download', :as => :download, :via => :get
    match '/download_request', :to => 'root#download_request', :as => :download_request, :via => :get
    match '/instructions', :to => 'root#instructions', :as => :instructions, :via => :get
    match '/disclaimer', :to => 'root#disclaimer', :as => :disclaimer, :via => :get
		match '/datasets', :to => 'root#explore_data', :as => :explore_data, :via => :get
		match '/datasets/:id', :to => 'root#explore_data_dashboard', :as => :explore_data_dashboard, :via => :get
    match '/datasets/:id/explore', :to => 'root#explore_data_show', :as => :explore_data_show, :via => :get
    match "/time_series" => redirect("/datasets")
    match '/time_series', :to => 'root#explore_time_series', :as => :explore_time, :via => :get
    match '/time_series/:id', :to => 'root#explore_time_series_dashboard', :as => :explore_time_series_dashboard, :via => :get
    match '/time_series/:id/explore', :to => 'root#explore_time_series_show', :as => :explore_time_series_show, :via => :get
    match '/private_share/:id', :to => 'root#private_share', :as => :private_share, :via => :get
    match '/generate_highlights', :to => 'root#generate_highlights', :as => :generate_highlights, :via => :post, :defaults => { :format => 'json' }

    # settings
    match '/settings', :to => 'settings#index', :as => :settings, :via => [:get, :put]
    match '/settings/get_api_token', :to => 'settings#get_api_token', :as => :settings_get_api_token, :via => :post
    match '/settings/delete_api_token/:id', :to => 'settings#delete_api_token', :as => :settings_delete_api_token, :via => :delete

    # support pages
    # * = glob that allows any characters including /
    match '/support', :to => 'support#index', :as => :support, :via => :get
    match '/support/*guide_book_id/guide/:guide_id', :to => 'support#guide', :as => :support_guide, :via => :get
    match '/support/*guide_book_id', :to => 'support#guide_book', :as => :support_guide_book, :via => :get


		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
