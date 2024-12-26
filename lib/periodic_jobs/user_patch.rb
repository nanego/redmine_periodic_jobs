require 'principal'
require 'user'

module PeriodicJobs
  module UserPatch
    def self.included(base)
      base.class_eval do
        has_many :periodic_jobs, :foreign_key => :author_id, :dependent => :nullify
      end
    end
  end
end

User.send(:include, PeriodicJobs::UserPatch)
