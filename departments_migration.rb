require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)

class DepartmentsMigration < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
    end
  end
end
