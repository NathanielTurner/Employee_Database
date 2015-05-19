require 'minitest/autorun'
require 'minitest/pride'
require 'active_record'
require './department.rb'
require './employee.rb'
require './departments_migration.rb'
require './employees_migration.rb'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)

ActiveRecord::Migration.verbose = false

class EmployeeReviewTest < Minitest::Test

  def setup
    EmployeesMigration.migrate(:up)
    DepartmentsMigration.migrate(:up)
  end

  def teardown
    EmployeesMigration.migrate(:down)
    DepartmentsMigration.migrate(:down)
  end

  def test_can_save_employees
    Employee.create(name: "Nate")
    assert_equal "Nate", Employee.last.name
    assert_equal 1, Employee.count
  end

  def test_can_save_departments
    Department.create(name: "R&D")
    assert_equal "R&D", Department.last.name
  end

  def test_employee_can_be_initialized_with_all_parameters
    Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    assert_equal "John Doe", Employee.last.name
    assert_equal "johndoe@johndoe.com", Employee.last.email
    assert_equal 1234567891, Employee.last.number
    assert_equal 10000, Employee.last.salary
  end

  def test_can_add_employee_to_department
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000,)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com",number: 1234567891, salary: 10000)
    department.add_employee(employee_one, employee_two)
    assert_equal 2, department.employees.count
    assert_equal department.id, employee_one.department_id
    assert_equal department.id, employee_two.department_id
    assert_equal "John Doe", department.employees.first.name
    assert_equal "Jane Doe", department.employees.last.name
    assert_equal "johndoe@johndoe.com", department.employees.first.email
    assert_equal "janedoe@janedoe.com", department.employees.last.email
  end

  # def test_can_add_review_text_to_employee
  #   employee = Employee.create(name: "John Doe", email: "johndoe@johndoe.com",number: 1234567891, salary: 10000)
  #   employee.add_review("This guy sucks.", "This guy is no good.")
  #   assert_equal 2,employee.reviews.length
  #   assert_equal "This guy sucks.", employee.reviews[0]
  #   assert_equal "This guy is no good.", employee.reviews[1]
  # end

  def test_can_mark_employee_satisfactory_or_unsatisfactory
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com",number: 1234567891, salary: 10000)
    employee_one.evaluation(10)
    employee_two.evaluation(5)
    assert_equal true, employee_one.performance
    assert_equal false, employee_two.performance
  end

  def test_can_give_raise_to_individual
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 7500)
    employee_one.give_raise(10)
    employee_two.give_raise(10)
    assert_equal 11000, employee_one.salary
    assert_equal 8250, employee_two.salary
  end

  def test_can_get_department_salary
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    department.add_employee(employee_one, employee_two)
    assert_equal 20000, department.salary
  end
#
  def test_can_give_department_raise
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Joe Doe", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    employee_one.evaluation(10)
    employee_two.evaluation(5)
    employee_three.evaluation(7)
    department.add_employee(employee_one, employee_two, employee_three)
    department.give_raise(500) do |e|
      e.salary < 10000 && e.performance == true
    end
    assert_equal 7250, employee_one.salary
    assert_equal 10000, employee_two.salary
    assert_equal 9250, employee_three.salary
  end
#
  def test_complete
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "Zeke", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    employee_two = Employee.create(name: "Wanda", email: "janedoe@janedoe.com", number: 1234567891, salary: 7500)
    # employee_one.add_review("This guys is awesome.", "This guy is good.")
    # employee_two.add_review("This girl sucks.", "This girl is no good.")
    employee_one.evaluation(10)
    employee_two.evaluation(5)
    department.add_employee(employee_one, employee_two)
    assert_equal 17500, department.salary
    assert_equal 10000, employee_one.salary
    assert_equal 7500, employee_two.salary
    employee_one.give_raise(10)
    employee_two.give_raise(10)
    assert_equal 11000, employee_one.salary
    assert_equal 8250, employee_two.salary
    department.give_raise(500) do |e|
      e.performance == true
    end
    assert_equal 19750, department.salary
    assert_equal 11500, employee_one.salary
    assert_equal 8250, employee_two.salary
  end
#
#   def test_review_evaluation
#     Department.create("R&D")
#     Employee.create(name: "Zeke", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
#     Employee.create(name: "Wanda", email: "janedoe@janedoe.com", number: 1234567891, salary: 7500)
#     department.add_employee(employee_one, employee_two)
#     employee_one.split_reviews
#     employee_two.split_reviews
#     employee_one.evaluate_reviews
#     employee_two.evaluate_reviews
#     assert_equal false, employee_one.performance
#     assert_equal true, employee_two.performance
#   end
#
end
