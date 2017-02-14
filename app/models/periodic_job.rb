class PeriodicJob < ActiveRecord::Base
  unloadable

  attr_accessible :title, :author_id, :path

  belongs_to :author, :class_name => 'User'

  default_scope { order('id desc') }
end
