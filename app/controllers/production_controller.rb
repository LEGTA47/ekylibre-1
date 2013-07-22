# == License
# Ekylibre - Simple ERP
# Copyright (C) 2009 Brice Texier, Thibaud Mérigon
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

class ProductionController < ApplicationController

  def index
    @operations = @current_company.operations.find(:all, :conditions=>{:moved_on=>nil})
  end

 
  dyta(:tools,  :conditions=>{:company_id=>['@current_company.id']}, :order=>"name") do |t|
    t.column :name, :url=>{:action=>:tool}
    t.column :text_nature
    t.column :consumption
    t.action :tool_update
    t.action :tool_delete, :method=>:delete, :confirm=>:are_you_sure, :if=>'RECORD.uses.size == 0'
  end

  def tools
  end

  dyta(:tool_operations, :model=>:tool_uses, :conditions=>{:company_id=>['@current_company.id'], :tool_id=>['session[:current_tool]']}, :order=>"created_at ASC") do |t|
    t.column :name,       :through=>:operation, :url=>{:action=>:operation}, :label=>tc(:name)
    t.column :planned_on, :through=>:operation, :label=>tc(:planned_on), :datatype=>:date
    t.column :moved_on,   :through=>:operation, :label=>tc(:moved_on)
    t.column :tools_list, :through=>:operation, :label=>tc(:tools_list)
    t.column :duration,   :through=>:operation, :label=>tc(:duration)
  end
  
  def tool
    return unless @tool = find_and_check(:tools)
    session[:current_tool] = @tool.id
    t3e @tool.attributes
  end
  
  manage :tools

  
  dyta(:shapes, :conditions=>{:company_id=>['@current_company.id']}, :order=>"name") do |t|
    t.column :name, :url=>{:action=>:shape}
    t.column :number
    t.column :area_measure, :datatype=>:decimal
    t.column :name, :through=>:area_unit
    t.column :description
    t.action :shape_update
    t.action :shape_delete, :method=>:delete, :confirm=>:are_you_sure
  end

  def shapes
  end

  manage :shapes

  dyta(:shape_operations, :model=>:operations,  :conditions=>{:company_id=>['@current_company.id'], :target_type=>Shape.name, :target_id=>['session[:current_shape]']}, :order=>"planned_on ASC") do |t|
    t.column :name, :url=>{:action=>:operation}
    t.column :name, :through=>:nature
    t.column :label, :through=>:responsible, :url=>{:controller=>:company, :action=>:user}
    t.column :planned_on
    t.column :moved_on
    t.column :tools_list
    t.column :duration
    t.action :operation_update, :image=>:update
    t.action :operation_delete, :method=>:delete, :image=>:delete, :confirm=>:are_you_sure
  end


  def shape
    return unless @shape = find_and_check(:shapes)
    session[:current_shape] = @shape.id
    t3e @shape.attributes
  end

  
  dyta(:operations, :conditions=>{:company_id=>['@current_company.id']}, :order=>" planned_on desc, name asc") do |t|
    t.column :name, :url=>{:action=>:operation}
    t.column :name, :through=>:nature
    t.column :label, :through=>:responsible, :url=>{:controller=>:company, :action=>:user}
    t.column :planned_on
    t.column :moved_on
    t.column :tools_list
    t.column :name, :through=>:target
    t.column :duration
    t.action :operation_update, :image=>:update
    t.action :operation_delete, :method=>:delete, :image=>:delete, :confirm=>:are_you_sure
  end

  def operations
  end

  dyta(:operation_lines, :conditions=>{:company_id=>['@current_company.id'], :operation_id=>['session[:current_operation_id]']}, :order=>"direction") do |t|
    t.column :direction_label
    t.column :name, :through=>:location, :url=>{:controller=>:management, :action=>:location}
    t.column :name, :through=>:product, :url=>{:controller=>:management, :action=>:product}
    t.column :quantity
    t.column :label, :through=>:unit
    t.column :name, :through=>:tracking, :url=>{:controller=>:management, :action=>:tracking}
    t.column :density_label
  end

  dyta(:operation_uses, :model=>:tool_uses, :conditions=>{:company_id=>['@current_company.id'], :operation_id=>['session[:current_operation_id]']}, :order=>"id") do |t|
    t.column :name, :through=>:tool, :url=>{:action=>:tool}
  end

  def operation
    return unless @operation = find_and_check(:operation)
    session[:current_operation_id] = @operation.id
    t3e @operation.attributes
  end
  
  def operation_create
    if request.post?
      # raise params.inspect
      @operation = @current_company.operations.new(params[:operation])
      @operation_lines = (params[:lines]||{}).values
      @operation_uses = (params[:uses]||{}).values
      redirect_to_back if @operation.save_with_uses_and_lines(@operation_uses, @operation_lines)
#       if @operation.save
#         @operation.set_lines(params[:lines].values) if params[:lines]
#         @operation.set_tools(params[:tools])
#         redirect_to_back
#       end
    else
      @operation = Operation.new(:planned_on=>Date.today, :responsible_id=>@current_user.id, :hour_duration=>2, :min_duration=>0)
    end
    render_form
  end

  def operation_update
    return unless @operation = find_and_check(:operations)
    session[:tool_ids] = []
    for tool in @operation.tools
      session[:tool_ids] << tool.id.to_s
    end
    if request.post?
      @operation.attributes = params[:operation]
      @operation_lines = (params[:lines]||{}).values
      @operation_uses = (params[:uses]||{}).values
      redirect_to_back if @operation.save_with_uses_and_lines(@operation_uses, @operation_lines)

#       if @operation.update_attributes(params[:operation])
#         @operation.set_lines(params[:lines].values) if params[:lines]
#         @operation.set_tools(params[:tools])
#         redirect_to_back
#       end
    end
    t3e @operation.attributes
    render_form
  end

  def operation_delete
    return unless @operation = find_and_check(:operations)
    @operation.destroy if request.post? or request.delete?
    redirect_to_current
  end

  dyli(:operation_products, [:code, :name], :model=>:products, :conditions => {:company_id=>['@current_company.id'], :active=>true})
  # dyli(:operation_out_products, [:code, :name], :model=>:products, :conditions => {:company_id=>['@current_company.id'], :active=>true, :to_produce=>true})

  def operation_line_create
    if request.xhr?
      render :partial=>'operation_line_row_form'
    else
      redirect_to :action=>:index
    end
  end


  def tool_use_create
    if request.xhr?
      render :partial=>'tool_use_row_form'
    else
      redirect_to :action=>:index
    end
  end


  dyta(:operation_natures, :conditions=>{:company_id=>['@current_company.id']}, :order=>"name" ) do |t|
    t.column :name
    t.column :description
    t.action :operation_nature_update
    t.action :operation_nature_delete, :method=>:delete, :confirm=>:are_you_sure
  end

  def operation_natures
  end

  manage :operation_natures



  dyta(:unvalidated_operations, :model=>:operations, :conditions=>{:moved_on=>nil, :company_id=>['@current_company.id']}) do |t|
    t.column :name 
    t.column :name, :through=>:nature
    t.column :label, :through=>:responsible, :url=>{:controller=>:company, :action=>:user}
    t.column :name, :through=>:target
    t.column :planned_on
    t.textbox :moved_on, :value=>'Date.today', :size=>10
    t.check :validated, :value=>'RECORD.planned_on<=Date.today'
  end

  def unvalidated_operations
    @operations = @current_company.operations.find(:all, :conditions=>{:moved_on=>nil})
    notify(:no_unvalidated_operations, :now) if @operations.size <= 0
    if request.post?
      for id, values in params[:unvalidated_operations]
        operation = @current_company.operations.find_by_id(id)
        operation.make((values[:moved_on].to_date rescue Date.today)) if operation and values[:validated].to_i == 1
        #operation.update_attributes!(:moved_on=>Date.today) if operation and values[:validated].to_i == 1
      end
      redirect_to :action=>:unvalidated_operations
    end
  end


end