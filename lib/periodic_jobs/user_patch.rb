require_dependency 'principal'
require_dependency 'user'

class User < Principal
  has_many :periodic_jobs,  :foreign_key => :author_id, :dependent => :destroy
end