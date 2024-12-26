class PeriodicJob < ApplicationRecord
  include Redmine::SafeAttributes

  safe_attributes :title, :author_id, :path, :periodicity

  belongs_to :author, :class_name => 'User'

  default_scope { order('id desc') }
end
