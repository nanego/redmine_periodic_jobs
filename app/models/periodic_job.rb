class PeriodicJob < ActiveRecord::Base
  include Redmine::SafeAttributes

  unloadable

  safe_attributes :title, :author_id, :path, :periodicity

  belongs_to :author, :class_name => 'User'

  default_scope { order('id desc') }
end
