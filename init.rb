Redmine::Plugin.register :redmine_periodic_jobs do
  name 'Redmine Periodic Jobs plugin'
  author 'Vincent ROBERT'
  description 'This Redmine plugin adds the ability to manage periodic tasks based on the CRON deamon'
  version '0.1.0'
  url 'https://github.com/nanego/redmine_periodic_jobs'
end

require_relative 'lib/periodic_jobs/hooks/view_layouts_base_html_head'

class ModelHook < Redmine::Hook::Listener
  def after_plugins_loaded(_context = {})
    require_relative 'lib/periodic_jobs/user_patch'
  end
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :periodic_jobs, { :controller => :periodic_jobs },
            :caption => :label_periodic_job_plural,
            :html => { :class => 'icon' }
end

# Support for Redmine 5
if Redmine::VERSION::MAJOR < 6
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
