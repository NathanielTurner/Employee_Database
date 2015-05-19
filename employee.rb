require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)

class Employee < ActiveRecord::Base
  belongs_to :department
  has_many :reviews

  def add_review(*text)
    text.map {|r| reviews << r }
  end

  def evaluation(number)
    if number >= 6
      self.performance = true
    else
      self.performance = false
    end
  end

  def evaluate_reviews
    positive = 0
    negative = 0
    negative_words = ["concern", "off", "bad", "poor", "inconsistent", "dissatisfied",
                 "less", "limitation", "interrupt", "disagree", "nasty",
                 "unacceptable", "awful", "innapropriate"]
    positive_words = ["good", "great", "alright", "well", "acceptable", "admirable",
                 "asset", "help", "Happy", "effective", "consistent", "satisfied",
                 "wonderful", "fantastic", "excellent", "amazing", "awsome",
                 "astonishing", "pleasure", "successfull", "enjoy", "devoted",
                 "perfect"]

    reviews.each do |r|
      negative_words.each {|a| r.review.match(a){negative += 1}}
      positive_words.each {|b| r.review.match(b){positive += 1}}

    end
    negative > positive ? self.update(performance: false) : self.update(performance: true)
  end

  def give_raise(percent)
    raise_amount = self.salary / percent
    self.salary += raise_amount
  end

  def split_reviews
    employee_reviews = File.open("./sample_reviews.txt").read.split(/POSITIVE REVIEW\s\d:|NEGATIVE REVIEW\s\d:/)
    review_text = employee_reviews[ employee_reviews.index{ |r| r.include?(self.name) } ].strip
    reviews << Review.create(review: "#{review_text}")
  end

  def palidrome?
    first_name = self.name.split(" ")[0].downcase
    if first_name == self.name.split(" ")[0].downcase.reverse
      self
    end
  end

  def performance_raise(percent)
    Employee.all.each do |e|
      if e.performance == true
        raise_amount = self.salary / percent
        self.update(salary: self.salary += raise_amount)
      end
    end
  end
end
