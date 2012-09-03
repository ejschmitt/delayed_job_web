module OrmStatusControl
  class << self 
    @has_orm = false
    @skip_loading = false
    attr_accessor :has_orm
    attr_accessor :skip_loading
  end
end