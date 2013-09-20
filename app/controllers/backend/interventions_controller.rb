# -*- coding: utf-8 -*-
# == License
# Ekylibre - Simple ERP
# Copyright (C) 2013 Brice Texier
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class Backend::InterventionsController < BackendController
  manage_restfully :t3e => {:name => "RECORD.name"}, :redirect_to => "{:controller => :procedures, :action => :play, :id => 'id'}"

  unroll

  list do |t|
    t.column :procedure, :url => true
    t.column :name, :through => :production, :url => true
    t.column :name, :through => :incident, :url => true
    t.column :state
    t.column :variables_names
    t.action :play
    t.action :destroy, :if => :destroyable?
  end

  list(:casts, :model => :intervention_casts, :conditions => {intervention_id: ['params[:id]']}, :order => "created_at DESC") do |t|
    t.column :name, :through => :actor, :url => true
    t.column :variable
    # t.column :indicator
    # t.column :measure_quantity
    # t.column :measure_unit
  end

  list(:operations, :conditions => {intervention_id: ['params[:id]']}, :order => "started_at DESC") do |t|
    # t.column :name, :url => true
    t.column :description
    # t.column :duration
    t.column :started_at
    t.column :stopped_at
  end


  # def play
  #   return unless @procedure = find_and_check
  #   # if @procedure.id != @procedure.playing.id
  #   #   redirect_to :action => :play, :id => @procedure.playing.id
  #   #   return
  #   # end
  #   t3e @procedure, :name => @procedure.name
  # end

  # # Register parameters and prepare for next step
  # def jump
  #   return unless @procedure = find_and_check
  #   Ekylibre::Record::Base.transaction do
  #     @procedure.variables.where("nomen NOT IN (?)", params[:variables].keys).each(&:destroy)
  #     for nomen, id in params[:variables]
  #       v = @procedure.variables.where(:nomen => nomen).first || @procedure.variables.build
  #       v.attributes = {:target_id => id.to_i, :nomen => nomen}
  #       v.save!
  #     end
  #     @procedure.save!
  #   end

  #   if params[:go_to]
  #     step = params[:go_to].to_sym
  #     followings = @procedure.followings
  #     raise StandardError.new("Following is not possible") unless followings.map(&:name).include?(step)
  #     # Squeeze intermediates
  #     future = nil
  #     for f in followings
  #       if f.name == step
  #         future = @procedure.load(f)
  #         break
  #       else
  #         @procedure.squeeze(f)
  #       end
  #     end
  #     redirect_to play_backend_procedure_url(future)
  #   elsif params[:redirect]
  #     redirect_to params[:redirect]
  #   else
  #     redirect_to @procedure
  #   end
  # end


end