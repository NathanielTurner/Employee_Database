require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3'
)


class Employee < ActiveRecord::Base
  #attr_reader :name, :email, :number, :reviews, :performance
  #attr_accessor :salary
  #def initialize(name:, email:, number:, salary:)
  #  @name = name
  #  @email = email
  #  @number = number
  #  @salary = salary
  #  @reviews = []
  #  @performance = nil
  #end

  def add_review(*reviews)
    reviews.map {|r| @reviews << r}
  end

  def evaluation(number)
    if number >= 6
      @performance = true
    else
      @performance = false
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

    @reviews.each do |r|
      negative_words.each do |a|
        if r.match(a)
          negative += 1
        end
      end
      positive_words.each {|b| r.match(b){positive += 1}}
    end
    negative > positive ? @performance = false : @performance = true
  end

  def give_raise(number)
    raise_amount = @salary / number
    @salary = @salary + raise_amount
  end

  def split_reviews
    reviews = File.open("./sample_reviews.txt").read.split(/POSITIVE REVIEW\s\d:|NEGATIVE REVIEW\s\d:/)
    @reviews << reviews[ reviews.index{ |r| r.include?(@name) } ].strip
  end
end
