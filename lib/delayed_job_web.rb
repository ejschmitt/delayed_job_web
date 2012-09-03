require 'orm_status_control'
if not OrmStatusControl::active_record_loaded?
  begin
    require 'active_record'
    OrmStatusControl::active_record = true
  rescue LoadError => e
  end
end
if not OrmStatusControl::mongoid_loaded?
  begin
    require 'mongoid'
    OrmStatusControl::mongoid = true
  rescue LoadError => e
  end
end
raise LoadError.new 'No orm/odm defined. Use ActiveRecord or Mongoid' unless OrmStatusControl::has_orm?
require 'delayed_job_web/application/app'