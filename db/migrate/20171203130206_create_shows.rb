class CreateShows < ActiveRecord::Migration[5.0]
  def change
    create_table :shows do |t|
      t.string :name
      t.string :path
      t.string :mood

      t.timestamps
    end
  end
end
