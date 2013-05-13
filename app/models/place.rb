# = Informations
#
# == License
#
# Ekylibre - Simple ERP
# Copyright (C) 2009-2013 Brice Texier, Thibaud Merigon
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: products
#
#  active                   :boolean          not null
#  address_id               :integer
#  area_measure             :decimal(19, 4)
#  area_unit_id             :integer
#  asset_id                 :integer
#  born_at                  :datetime
#  content_maximal_quantity :decimal(19, 4)   default(0.0), not null
#  content_nature_id        :integer
#  content_unit_id          :integer
#  created_at               :datetime         not null
#  creator_id               :integer
#  current_place_id         :integer
#  dead_at                  :datetime
#  description              :text
#  external                 :boolean          not null
#  father_id                :integer
#  id                       :integer          not null, primary key
#  identification_number    :string(255)
#  lock_version             :integer          default(0), not null
#  maximal_quantity         :decimal(19, 4)   default(0.0), not null
#  minimal_quantity         :decimal(19, 4)   default(0.0), not null
#  mother_id                :integer
#  name                     :string(255)      not null
#  nature_id                :integer          not null
#  number                   :string(255)      not null
#  owner_id                 :integer          not null
#  parent_id                :integer
#  picture_content_type     :string(255)
#  picture_file_name        :string(255)
#  picture_file_size        :integer
#  picture_updated_at       :datetime
#  real_quantity            :decimal(19, 4)   default(0.0), not null
#  reproductor              :boolean          not null
#  reservoir                :boolean          not null
#  sex                      :string(255)
#  shape                    :spatial({:srid=>
#  tracking_id              :integer
#  type                     :string(255)      not null
#  unit_id                  :integer          not null
#  updated_at               :datetime         not null
#  updater_id               :integer
#  variety_id               :integer          not null
#  virtual_quantity         :decimal(19, 4)   default(0.0), not null
#  work_number              :string(255)
#
class Place < Product
  # TODO Removes :buildings not the place for this
  # has_many :buildings, :class_name => "Building", :foreign_key => :parent_place_id
  has_many :children, :class_name => "Place", :foreign_key => :parent_id
  belongs_to :parent, :class_name => "Place"

  default_scope -> { select("*, ST_AsSVG(shape) AS shape_svg_path, ST_XMin(shape) AS x_min, ST_XMax(shape) AS x_max, ST_YMin(shape) AS y_min, ST_YMax(shape) AS y_max, ST_XMax(shape) - ST_XMin(shape) AS shape_width, ST_YMax(shape) - ST_YMin(shape) AS shape_height") }

  # Select SVG path of shape column
  def self.with_shape_svg_path(rel = 0, maxdecimaldigits = 15)
    select("ST_AsSVG(shape, #{rel}, #{maxdecimaldigits}) AS shape_svg_path")
  end

  def bounds
    return [[self.x_min, self.y_min], [self.x_max, self.y_max]]
  end

  def self.view_box
    x_min = self.minimum("ST_XMin(shape)").to_d
    x_max = self.maximum("ST_XMax(shape)").to_d
    y_min = self.minimum("ST_YMin(shape)").to_d
    y_max = self.maximum("ST_YMax(shape)").to_d
    return [x_min, -y_max, (x_max - x_min), (y_max - y_min)]
  end

  def view_box
    return [self.x_min, -1 * self.y_max.to_d, self.shape_width, self.shape_height]
  end

end
