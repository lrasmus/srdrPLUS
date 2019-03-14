class DbSrdr < ActiveRecord::Base
  establish_connection DB_SRDR
  self.abstract_class = true
end
