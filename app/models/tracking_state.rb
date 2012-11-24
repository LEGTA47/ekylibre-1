# = Informations
#
# == License
#
# Ekylibre - Simple ERP
# Copyright (C) 2009-2012 Brice Texier, Thibaud Merigon
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
# == Table: tracking_states
#
#  atmospheric_pressure         :decimal(19, 4)
#  comment                      :text
#  created_at                   :datetime         not null
#  creator_id                   :integer
#  examinated_at                :datetime         not null
#  id                           :integer          not null, primary key
#  lock_version                 :integer          default(0), not null
#  luminance                    :decimal(19, 4)
#  net_weight                   :decimal(19, 4)
#  production_chain_conveyor_id :integer
#  relative_humidity            :decimal(19, 4)
#  responsible_id               :integer          not null
#  temperature                  :decimal(19, 4)
#  total_weight                 :decimal(19, 4)
#  tracking_id                  :integer          not null
#  updated_at                   :datetime         not null
#  updater_id                   :integer
#


class TrackingState < CompanyRecord
  attr_readonly :tracking_id
  belongs_to :tracking

  #[VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates_numericality_of :atmospheric_pressure, :luminance, :net_weight, :relative_humidity, :temperature, :total_weight, :allow_nil => true
  validates_presence_of :examinated_at, :tracking
  #]VALIDATORS]

  @@report_columns = [:total_weight, :net_weight, :temperature, :relative_humidity, :luminance, :atmospheric_pressure, :comment]

  def self.report_columns
    @@report_columns.collect{|x| self.columns_hash[x.to_s]}
  end

end
