Redmine::Plugin.register :daily_reports do
  name 'Daily Reports plugin'
  author 'Alexander Bagiev'
  description 'This plugin provides daily status page with possibility to display users issue updates per days.'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  project_module :daily_reports do
    permission :view_daily_reports, :daily_reports => :index
    permission :manage_daily_status, :daily_statuses => :save
  end

  menu :project_menu, :daily_reports,
    { :controller => 'daily_reports', :action => 'index' },
    :caption => :daily_reports,
    :last => true
end
