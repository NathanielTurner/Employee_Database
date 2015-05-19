require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)

class EmployeesMigration < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.references :department
      t.string :name
      t.string :email
      t.integer :salary
      t.boolean :performance
      t.integer :number
      t.string :reviews
    end
  end
end
