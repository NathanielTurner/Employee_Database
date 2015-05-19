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
    self.employees.select {|e| e.palidrome?}
  end

  def most_employees
    most = nil
    count = 0
    Department.all.each do |d|
      if d.total_employees > count
        most = d
        count = d.total_employees
      end
    end
    most
  end

  def merge(other)
    other.employees.each do |a|
      a.update(department_id: self.id)
    end
  end


end
