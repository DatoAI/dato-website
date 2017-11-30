require 'test_helper'

class DashboardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

    
  test "An user with common role can't access the dashboard" do
    user = create(:user)
    
    # Sign in
    sign_in(user)
    visit(dashboard_home_path)

    page.assert_selector('div.notification.is-danger', text: 'Você não pode realizar essa ação', visible: true)
  end 

  test "An admin can access the dashboard" do
    admin = create(:admin)
    
    # Sign in
    sign_in(admin)
    visit(dashboard_home_path)

    page.assert_selector('h1.title', text: 'Painel Administrativo')
  end 

end  