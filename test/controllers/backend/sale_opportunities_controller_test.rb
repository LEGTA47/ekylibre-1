require 'test_helper'
class Backend::SaleOpportunitiesControllerTest < ActionController::TestCase
  test_restfully_all_actions except: [:select, :attach, :detach, :finish]
end
