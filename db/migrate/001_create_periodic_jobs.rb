class CreatePeriodicJobs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :periodic_jobs do |t|
      t.column :title, :string
      t.column :author_id, :integer
      t.column :path, :string
    end
  end

  def self.down
    drop_table :periodic_jobs
  end
end
