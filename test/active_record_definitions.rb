module Mongoid
  class Criteria < Array
  end
end
module ActiveRecord
  class Base
  end
end
class Delayed::Job < ActiveRecord::Base
  class DelayedJobFake < Array
    # fake out arel
    def order(*args)
      DelayedJobFake.new
    end

    def offset(*args)
      DelayedJobFake.new
    end

    def limit(*args)
      DelayedJobFake.new
    end
  end

  def self.where(*args)
    DelayedJobFake.new
  end

  def self.count(*args)
    0
  end
end