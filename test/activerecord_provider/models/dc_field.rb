class DCField < ActiveRecord::Base
  default_scope includes(:publication).where("dc_publications.available_from >= :date", date: Date.yesterday)

  inheritance_column = 'DONOTINHERIT'
  has_and_belongs_to_many :sets,
    :join_table => "dc_fields_dc_sets",
    :foreign_key => "dc_field_id",
    :class_name => "DCSet"
  belongs_to :publication, class_name: 'DCPublication', foreign_key: :dc_publication_id
end
