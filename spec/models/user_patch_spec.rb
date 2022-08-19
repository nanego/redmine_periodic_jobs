require "spec_helper"
require File.dirname(__FILE__) + '/../../lib/periodic_jobs/user_patch'

describe "UserPatch" do
  fixtures :users
 
  it "should Update periodic_jobs table in case of cascade deleting" do
  	user = User.last
    PeriodicJob.create(:title =>  'test1', author_id: user.id)
    PeriodicJob.create(:title =>  'test2', author_id: user.id)
    expect do
    	user.destroy
    end.to change{ PeriodicJob.count }.by(-2)
  end
end
