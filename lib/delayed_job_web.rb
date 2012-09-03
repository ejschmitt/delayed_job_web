require 'orm_status_control'
begin
  require 'active_record'
  OrmStatusControl::status.has_orm ||= true
rescue LoadError => e
  module ActiveRecord
    class Base
    end
  end
end
begin
  require 'mongoid'
  OrmStatusControl::status.has_orm ||= true
rescue LoadError => e
  module Mongoid
    class Criteria  < Array
    end
  end
end
raise LoadError.new 'No orm defined. Use ActiveRecord or Mongoid' unless OrmStatusControl::status.has_orm
require 'delayed_job_web/application/app'