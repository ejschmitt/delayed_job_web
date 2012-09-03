require 'orm_status_control'
if not OrmStatusControl::skip_loading
  begin
    require 'active_record'
    OrmStatusControl::has_orm ||= true
  rescue LoadError => e
    module ActiveRecord
      class Base
      end
    end
  end
  begin
    require 'mongoid'
    OrmStatusControl::has_orm ||= true
  rescue LoadError => e
    module Mongoid
      class Criteria  < Array
      end
    end
  end
end
raise LoadError.new 'No orm defined. Use ActiveRecord or Mongoid' unless OrmStatusControl::has_orm
require 'delayed_job_web/application/app'