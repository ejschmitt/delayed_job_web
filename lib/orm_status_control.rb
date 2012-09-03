module OrmStatusControl
  def self.status
    @orm_status ||= OrmStatus.new
  end
  class OrmStatus
    def initialize
      @has_orm = false
    end
    attr_accessor :has_orm
  end
end