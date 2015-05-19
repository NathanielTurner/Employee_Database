require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)


class Department < ActiveRecord::Base
  has_many :employees

  def add_employee(*people)
    people.map {|e| employees << e}
  end

  def salary
    self.employees.reduce(0) {|sum, e| sum + e.salary}
  end

  def give_raise(num)
    good = self.employees.select {|e| yield(e)}
    good.each {|e| e.salary = e.salary + (num / good.length)}
  end

  def total_employees
    self.employees.count
  end

  def least_payed
    self.employees.order(:salary).first
  end

  def sort_alphabetically
    self.employees.order(:name)
  end

  def sort_above_average
    avg = self.salary/self.employees.count
    self.employees.select {|a| a.salary > avg}
  end

  def find_palindrome
    self.employees.select
  end
end
