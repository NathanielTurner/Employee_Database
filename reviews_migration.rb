require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)

class ReviewsMigration < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.text :review
      t.references :employee
    end
  end
end
