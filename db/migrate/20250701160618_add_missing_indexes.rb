class AddMissingIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :periodic_jobs, :author_id, if_not_exists: true
  end
end
