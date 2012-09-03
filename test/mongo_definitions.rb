#cleaning up
Delayed.send(:remove_const, :Job)
Object.send(:remove_const, :Mongoid)
module Mongoid
  class Criteria < Array
    def desc(*args)
      Mongoid::Criteria.new
    end
    def offset(*args)
      Mongoid::Criteria.new
    end
    def limit(*args)
      Mongoid::Criteria.new
    end
  end
end
class Symbol
  def exists
    true
  end
end
class Delayed::Job
  def self.where(*args)
    Mongoid::Criteria.new
  end
  def self.count(*args)
    0
  end
end