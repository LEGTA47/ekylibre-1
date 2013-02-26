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
# == Table: product_memberships
#
#  created_at   :datetime         not null
#  creator_id   :integer
#  group_id     :integer          not null
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  product_id   :integer          not null
#  started_at   :datetime         not null
#  stopped_at   :datetime
#  updated_at   :datetime         not null
#  updater_id   :integer
#


class ProductMembership < Ekylibre::Record::Base
  attr_accessible :started_at, :stopped_at, :group_id, :product_id
  belongs_to :group, :class_name => "ProductGroup"
  belongs_to :product, :class_name => "Product"
  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_presence_of :group, :product, :started_at
  #]VALIDATORS]

  validate do
    # TODO Checks that no time overlaps can occur
    errors.add(:started_at, :invalid) unless self.similars.where("stopped_at IS NULL AND (started_at IS NOT NULL OR started_at <=?)", self.started_at).count.zero?
  end

  def similars
    self.class.where(:group_id => self.group_id, :product_id => self.product_id)
  end

end
