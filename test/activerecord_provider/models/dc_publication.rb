class DCPublication < ActiveRecord::Base
  has_many :dc_fields, class_name: 'DCField', foreign_key: 'dc_publication_id'
end