require 'delayed_job'

class Delayed::Job
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

    def size(*args)
      {}
    end
  end

  def self.group(*args)
    DelayedJobFake.new
  end

  def self.where(*args)
    DelayedJobFake.new
  end

  def self.count(*args)
    0
  end

  def self.order(*args)
    DelayedJobFake.new
  end

  def self.find(*args)
    DelayedJobFake.new
  end
end
