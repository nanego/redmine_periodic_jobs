class AddPeriodicityToPeriodicJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :periodic_jobs, :periodicity, :string
  end
end
