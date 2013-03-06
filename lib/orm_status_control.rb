module OrmStatusControl
  class << self 
    @mongoid = @active_record = false
    def mongoid_loaded?
      @mongoid
    end
    def active_record_loaded?
      @active_record
    end
    def has_orm?
      mongoid_loaded? || active_record_loaded?
    end
    attr_accessor :mongoid
    attr_accessor :active_record
  end
end