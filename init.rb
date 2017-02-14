require 'periodic_jobs/hooks/view_layouts_base_html_head'

Redmine::Plugin.register :redmine_periodic_jobs do
  name 'Redmine Periodic Jobs plugin'
  author 'Vincent ROBERT'
  description 'This Redmine plugin adds the ability to manage periodic tasks based on the CRON deamon'
  version '0.1.0'
  url 'https://github.com/nanego/redmine_periodic_jobs'
  author_url 'mailto:contact@vincent-robert.com'
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :periodic_jobs, {:controller => :periodic_jobs}, :caption => :label_periodic_job_plural
end
