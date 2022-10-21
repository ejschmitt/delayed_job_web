# frozen_string_literal: true

require 'delayed_job'

module Delayed
  class Job
    class DelayedJobFake < Array
      # fake out arel
      def order(*_args)
        DelayedJobFake.new
      end

      def offset(*_args)
        DelayedJobFake.new
      end

      def limit(*_args)
        DelayedJobFake.new
      end

      def size(*_args)
        {}
      end
    end

    def self.group(*_args)
      DelayedJobFake.new
    end

    def self.where(*_args)
      DelayedJobFake.new
    end

    def self.count(*_args)
      0
    end

    def self.order(*_args)
      DelayedJobFake.new
    end

    def self.find(*_args)
      DelayedJobFake.new
    end
  end
end
