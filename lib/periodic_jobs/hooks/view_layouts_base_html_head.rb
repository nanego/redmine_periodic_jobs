module PeriodicJobsPlugin
  class StylesheetHook < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag "periodic_jobs", :plugin => :redmine_periodic_jobs
    end
  end
end
