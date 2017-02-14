class AddPeriodicityToPeriodicJobs < ActiveRecord::Migration
  def change
    add_column :periodic_jobs, :periodicity, :string
  end
end
