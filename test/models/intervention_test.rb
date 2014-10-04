# = Informations
#
# == License
#
# Ekylibre ERP - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2014 Brice Texier, David Joulin
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
# == Table: interventions
#
#  created_at                  :datetime         not null
#  creator_id                  :integer
#  description                 :text
#  event_id                    :integer
#  id                          :integer          not null, primary key
#  issue_id                    :integer
#  lock_version                :integer          default(0), not null
#  natures                     :string(255)      not null
#  number                      :string(255)
#  parameters                  :text
#  prescription_id             :integer
#  production_id               :integer          not null
#  production_support_id       :integer
#  provisional                 :boolean          not null
#  provisional_intervention_id :integer
#  recommended                 :boolean          not null
#  recommender_id              :integer
#  reference_name              :string(255)      not null
#  ressource_id                :integer
#  ressource_type              :string(255)
#  started_at                  :datetime
#  state                       :string(255)      not null
#  stopped_at                  :datetime
#  updated_at                  :datetime         not null
#  updater_id                  :integer
#
require 'test_helper'

class InterventionTest < ActiveSupport::TestCase

  test "scopes" do
    cast = intervention_casts(:intervention_casts_001)
    actor = cast.actor
    assert_nothing_raised do
      Intervention.with_generic_cast(:tool, actor)
    end
    assert_nothing_raised do
      Intervention.with_generic_cast("tool", actor)
    end
    assert_nothing_raised do
      Intervention.with_cast(:'grinding-tool', actor)
    end
    assert_nothing_raised do
      Intervention.with_cast('grinding-tool', actor)
    end
    assert_raise ArgumentError do
      Intervention.with_cast("tool", actor)
    end
    assert_raise ArgumentError do
      Intervention.with_cast(:tool, actor)
    end
  end

end
