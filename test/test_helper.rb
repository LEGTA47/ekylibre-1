# -*- coding: utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

# Removes use of shoulda gem until bug is not fixed for Rails >= 1.9.3
# Use specific file lib/shoulda/context/context.rb
# TODO: Re-add shoulda-context in Gemfile ASAP
require File.join(File.dirname(__FILE__), 'shoulda-context')
class Test::Unit::TestCase
  include Shoulda::Context::InstanceMethods
  extend Shoulda::Context::ClassMethods
end


class CapybaraIntegrationTest < ActionController::IntegrationTest
  include Capybara::DSL
end



class ActiveSupport::TestCase


  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def actions_of(cont)
    User.rights[cont].keys
  end

  def login(name, password)
    # print "L"
    old_controller = @controller
    @controller = SessionsController.new
    post :create, :name=>name, :password=>password
    url = {:controller=>:dashboards, :action=>:index}
    assert_redirected_to root_url, root_url.inspect
    assert_not_nil(session[:user_id])
    @controller = old_controller
  end

  def fast_login(user)
    # print "V"
    @controller.send(:init_session, user)
  end


end



class ActionController::TestCase
  if Rails.version.match(/^2\.3/)
    def response
      @response
    end
  end



  def self.test_restfully_all_actions(options={})
    controller ||= self.controller_class.to_s[0..-11].underscore.to_sym
    code  = ""
    code << "context 'A #{controller} controller' do\n"
    code << "  setup do\n"
    code << "    @user = users(:users_001)\n"
    # code << "    login(@user.name, @user.comment)\n"
    code << "    login('gendo', 'secret')\n"
    # code << "    fast_login(@user)\n"
    code << "  end\n"
    # code << "  teardown do\n"
    # code << "    @user = nil\n"
    # code << "    reset_session\n"
    # code << "  end\n"
    # code << "  should 'have restful actions' do\n"
    except = options.delete(:except)||[]
    except = [except] unless except.is_a? Array
    except << :formize
    # for ignored in except
    #   puts "Ignore: #{controller}##{ignored}"
    # end
    return unless User.rights[controller]
    for action in User.rights[controller].keys.sort{|a,b| a.to_s<=>b.to_s} # .delete_if{|x| ![:index, :new, :create, :edit, :update, :destroy, :show].include?(x.to_sym)} # .delete_if{|x| except.include? x}
      if except.include? action
        puts "Ignore: #{controller}##{action}"
        next
      end

      code << "  should 'execute :#{action}' do\n"

      unless mode = options[action] and options[action].is_a? Symbol
        action_name = action.to_s
        mode = if action_name.match(/^(index|new)$/) # GET without ID
                 :index
               elsif action_name.match(/^(show|edit)$/) # GET with ID
                 :show
               elsif action_name.match(/^(create|load)$/) # POST without ID
                 :create
               elsif action_name.match(/^(update)$/) # PUT with ID
                 :update
               elsif action_name.match(/^(destroy)$/) # DELETE with ID
                 :destroy
               elsif action_name.match(/^list(_\w+)?$/) # GET list
                 :list
               elsif action_name.match(/^(duplicate|up|down|lock|unlock|increment|decrement|propose|confirm|refuse|invoice|abort|correct|finish|propose_and_invoice|sort)$/) # POST with ID
                 :touch
               end
      end

      model = controller.to_s.singularize
      if options[action].is_a? Hash
        # code << "    get :#{action}\n"
        # code << "    assert_response :redirect\n"
        code << "    get :#{action}, #{options[action].inspect[1..-2]}\n"
        code << "    assert_response :success, \"The action #{action.inspect} does not seem to support GET method \#{redirect_to_url} / \#{flash.inspect}\"\n"
        # code << "    assert_select('html body div#body', 1, '#{action}'+response.inspect)\n"
      elsif mode == :index
        code << "    get :#{action}\n"
        code << '    assert_response :success, "Flash: #{flash.inspect}"'+"\n"
      elsif mode == :show
        # code << "    assert_raise ActionController::RoutingError, 'GET #{controller}/#{action}' do\n"
        # code << "      get :#{action}\n"
        # code << "    end\n"
        code << "    get :#{action}, :id=>'NaID'\n"
        code << "    get :#{action}, :id=>1\n"
        code << '    assert_response :success, "Flash: #{flash.inspect}"'+"\n"
        code << "    assert_not_nil assigns(:#{model})\n"
      elsif mode == :create
        klass = model.classify.constantize
        protected_attributes = klass.protected_attributes.to_a
        attributes = klass.attribute_names - protected_attributes
        protected_attributes -= ["id", "type"]

        code << "    #{model} = #{controller}(:#{controller}_001)\n"
        code << "    assert_nothing_raised do\n"
        code << "      post :#{action}, :#{model}=>{"+attributes.collect{|a| ":#{a}=>#{model}.#{a}"}.join(', ')+"}\n"
        code << "    end\n"
        if protected_attributes.size > 0
          code << "    assert_raise(ActiveModel::MassAssignmentSecurity::Error, 'POST #{controller}/#{action}') do\n"
          code << "      post :#{action}, :#{model}=>#{model}.attributes\n"
          code << "    end\n"
        end
      elsif mode == :update
        klass = model.classify.constantize
        protected_attributes = klass.protected_attributes.to_a
        attributes = klass.attribute_names - protected_attributes
        protected_attributes -= ["id", "type"]

        code << "    #{model} = #{controller}(:#{controller}_001)\n"
        code << "    assert_nothing_raised do\n"
        code << "      put :#{action}, :id=>#{model}.id, :#{model}=>{"+attributes.collect{|a| ":#{a}=>#{model}.#{a}"}.join(', ')+"}\n"
        code << "    end\n"
        if protected_attributes.size > 0
          code << "    assert_raise(ActiveModel::MassAssignmentSecurity::Error, 'PUT #{controller}/#{action}/:id') do\n"
          code << "      put :#{action}, :id=>#{model}.id, :#{model}=>#{model}.attributes\n"
          code << "    end\n"
        end
      elsif mode == :destroy
        code << "    assert_nothing_raised do\n"
        code << "      delete :#{action}, :id=>2\n"
        code << "    end\n"
        code << "    assert_response :redirect\n"
      elsif mode == :list
        code << "    get :#{action}\n"
        code << "    assert_response :success, \"The action #{action.inspect} does not seem to support GET method \#{redirect_to_url} / \#{flash.inspect}\"\n"
        for format in [:csv, :xcsv, :ods]
          code << "    get :#{action}, :format=>:#{format}\n"
          code << "    assert_response :success, 'Action #{action} does not esport in format #{format}'\n"
        end
      elsif mode == :touch
        # code << "    assert_raise ActionController::RoutingError, 'POST #{controller}/#{action}' do\n"
        # code << "      post :#{action}\n"
        # code << "    end\n"
        code << "    post :#{action}, :id=>'NaID'\n"
        code << "    post :#{action}, :id=>1\n"
        code << "    assert_response :redirect\n"
      elsif mode == :get_and_post # with ID
        # code << "    assert_raise ActionController::RoutingError, 'GET #{controller}/#{action}' do\n"
        # code << "      get :#{action}\n"
        # code << "    end\n"
        code << "    get :#{action}, :id=>'NaID'\n"
        code << "    get :#{action}, :id=>1\n"
        code << '    assert_response :success, "Flash: #{flash.inspect}"'+"\n"
      elsif mode == :index_xhr
        code << "    get :#{action}\n"
        code << "    assert_response :redirect\n"
        code << "    xhr :get, :#{action}\n"
        code << '    assert_response :success, "Flash: #{flash.inspect}"'+"\n"
      elsif mode == :show_xhr
        code << "    get :#{action}, :id=>1\n"
        code << "    assert_response :redirect\n"
        code << "    xhr :get, :#{action}, :id=>1\n"
        code << "    assert_not_nil assigns(:#{model})\n"
      else
        code << "    get :#{action}\n"
        code << "    assert_response :success, \"The action #{action.inspect} does not seem to support GET method \#{redirect_to_url} / \#{flash.inspect}\"\n"
        code << "    assert_select('html body div#body', 1, '#{action}')\n" # +response.inspect
      end
      code << "  end\n"
    end
    # code << "  end\n"
    code << "end\n"

    # code.split("\n").each_with_index{|line, x| puts((x+1).to_s.rjust(4)+": "+line)}
    class_eval(code, "#{__FILE__}:#{__LINE__}")

  end
end

