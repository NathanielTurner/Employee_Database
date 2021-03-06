require 'minitest/autorun'
require 'minitest/pride'
require 'active_record'
require './department.rb'
require './employee.rb'
require './review.rb'
require './departments_migration.rb'
require './employees_migration.rb'
require './reviews_migration.rb'


ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)

ActiveRecord::Migration.verbose = false

class EmployeeReviewTest < Minitest::Test

  def setup
    EmployeesMigration.migrate(:up)
    DepartmentsMigration.migrate(:up)
    ReviewsMigration.migrate(:up)
  end

  def teardown
    EmployeesMigration.migrate(:down)
    DepartmentsMigration.migrate(:down)
    ReviewsMigration.migrate(:down)
  end

  def test_can_save_reviews
    Review.create(review: "This guy is awful.")
    assert_equal 1, Review.count
    assert_equal "This guy is awful.", Review.last.review
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

  def test_can_add_review_text_to_employee
    employee = Employee.create(name: "John Doe", email: "johndoe@johndoe.com",number: 1234567891, salary: 10000)
    review_one = Review.create(review: "This guy sucks.")
    review_two = Review.create(review: "This guy is no good.")
    employee.add_review(review_one, review_two)
    assert_equal 2, employee.reviews.count
    assert_equal "This guy sucks.", employee.reviews.first.review
    assert_equal "This guy is no good.", employee.reviews.last.review
  end

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

  def test_complete
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "Zeke", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    employee_two = Employee.create(name: "Wanda", email: "janedoe@janedoe.com", number: 1234567891, salary: 7500)
    review_one = Review.create(review: "This guy sucks.")
    review_two = Review.create(review: "This guy is no good.")
    employee_one.add_review(review_one, review_two)
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

  def test_can_count_all_employees
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Joe Doe", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    department.add_employee(employee_one, employee_two, employee_three)
    assert_equal 3, department.total_employees
  end

  def test_can_tell_who_makes_the_least
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Joe Doe", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    department.add_employee(employee_one, employee_two, employee_three)
    assert_equal employee_one, department.least_payed
  end

  def test_can_order_employees_alphabetically
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Joe Doe", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    department.add_employee(employee_one, employee_two, employee_three)
    assert_equal employee_two, department.sort_alphabetically.first
    assert_equal employee_one, department.sort_alphabetically.last
  end

  def test_can_tell_whose_above_average
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Joe Doe", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    department.add_employee(employee_one, employee_two, employee_three)
    assert_equal [employee_two, employee_three], department.sort_above_average
  end

  def test_can_find_palindrome_names
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Bob Retter", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    department.add_employee(employee_one, employee_two, employee_three)
    assert_equal [Employee.find(3)], department.find_palindrome
  end

  def test_can_tell_which_department_has_more_employees
    department_one = Department.create(name: "R&D")
    department_two = Department.create(name: "SectorX")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Bob Retter", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    employee_four = Employee.create(name: "John Dee", email: "johndee@johndee.com", number: 1234567891, salary: 90500)
    employee_five = Employee.create(name: "Jane Dee", email: "janedee@janedee.com", number: 1234567891, salary: 10010)
    employee_six = Employee.create(name: "Joe Dee", email: "joedee@janedee.com", number: 1234567891, salary: 15000)
    department_one.add_employee(employee_one, employee_two, employee_three, employee_four)
    department_two.add_employee(employee_five, employee_six)
    assert_equal Department.find(1), department_one.most_employees
  end

  def test_departments_can_merge
    department_one = Department.create(name: "R&D")
    department_two = Department.create(name: "SectorX")
    employee_one = Employee.create(name: "John Doe", email: "johndoe@johndoe.com", number: 1234567891, salary: 7000)
    employee_two = Employee.create(name: "Jane Doe", email: "janedoe@janedoe.com", number: 1234567891, salary: 10000)
    employee_three = Employee.create(name: "Bob Retter", email: "joedoe@janedoe.com", number: 1234567891, salary: 9000)
    employee_four = Employee.create(name: "John Dee", email: "johndee@johndee.com", number: 1234567891, salary: 90500)
    employee_five = Employee.create(name: "Jane Dee", email: "janedee@janedee.com", number: 1234567891, salary: 10010)
    employee_six = Employee.create(name: "Joe Dee", email: "joedee@janedee.com", number: 1234567891, salary: 15000)
    department_one.add_employee(employee_one, employee_two, employee_three, employee_four)
    department_two.add_employee(employee_five, employee_six)
    department_two.merge(department_one)
    assert_equal 6, department_two.total_employees
  end

  def test_review_evaluation
    department = Department.create(name: "R&D")
    employee_one = Employee.create(name: "Zeke", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    employee_two = Employee.create(name: "Wanda", email: "janedoe@janedoe.com", number: 1234567891, salary: 7500)
    department.add_employee(employee_one, employee_two)
    employee_one.split_reviews
    employee_two.split_reviews
    employee_one.evaluate_reviews
    employee_two.evaluate_reviews
    assert_equal false, employee_one.performance
    assert_equal true, employee_two.performance
  end

  def test_cross_department_raise
    department_one = Department.create(name: "R&D")
    department_two = Department.create(name: "SectorX")
    employee_one = Employee.create(name: "Zeke", email: "johndoe@johndoe.com", number: 1234567891, salary: 10000)
    employee_two = Employee.create(name: "Wanda", email: "janedoe@janedoe.com", number: 1234567891, salary: 7000)
    department_one.add_employee(employee_one)
    department_two.add_employee(employee_two)
    employee_one.split_reviews
    employee_two.split_reviews
    employee_one.evaluate_reviews
    employee_two.evaluate_reviews
    assert_equal false, Employee.find(1).performance
    assert_equal true, Employee.find(2).performance
    employee_one.performance_raise(10)
    assert_equal 11000, employee_one.salary
    assert_equal 7000, employee_two.salary
  end

end
