# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match '/projects/:id/daily_reports', :to => 'daily_reports#index', :via => :get
