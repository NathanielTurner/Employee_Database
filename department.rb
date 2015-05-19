require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)


class Department < ActiveRecord::Base
#  attr_reader :name, :employees
#  def initialize(name)
#    @name = name
#    @employees = []
#  end

  def add_employee(*people)
    people.map {|e| self.employees << e}
  end

  def salary
    @employees.reduce(0) {|sum, e| sum + e.salary}
  end

  def give_raise(num)
    good = @employees.select {|e| yield(e)}
    good.each {|e| e.salary = e.salary + (num / good.length)}
  end
end
