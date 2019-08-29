class DCFieldScoped < ActiveRecord::Base
  self.table_name = 'dc_fields'

  default_scope joins('LEFT JOIN dc_fields_dc_sets ON dc_fields.id = dc_fields_dc_sets.dc_field_id')

  inheritance_column = 'DONOTINHERIT'
  has_and_belongs_to_many :sets,
                          :join_table => "dc_fields_dc_sets",
                          :foreign_key => "dc_field_id",
                          :class_name => "DCSet"
end

