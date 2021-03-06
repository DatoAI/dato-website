require 'test_helper'

class CreateCompetitionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "A regular user can't create a competition" do
    chuck = create(:user)

    # Sign in
    sign_in(chuck)
    visit(competitions_path)

    # Ensure there is no create competition button
    refute(page.has_link?('Criar'))

    # Try direct access to create competition
    visit(new_competition_path)
    page.assert_selector('div.notification.is-danger', text: 'Você não pode realizar essa ação', visible: true)
    assert_equal root_path, page.current_path
  end

  test "An admin can create a competition" do
    labels = {
      name: Competition.human_attribute_name(:name),
      expected_csv: Competition.human_attribute_name(:expected_csv),
      markdown: Instruction.human_attribute_name(:markdown)
    }

    admin = create(:admin)
    competition_name = "Competição A123"

    # Sign in
    sign_in(admin)
    visit(competitions_path)

    # Look for create competition button
    assert(page.has_link?('Criar'))
    click_link('Criar')

    # Fill the form
    assert_difference ->{ Instruction.count }, Competition::REQUIRED_INSTRUCTIONS.size do
      assert_difference ->{ Competition.count } do
        fill_in(labels[:name], with: competition_name, id: 'competition_name')
        attach_file(labels[:expected_csv], random_csv)
        fill_in(labels[:markdown], with: 'Lorem Ipsum', id: 'competition_instructions_attributes_0_markdown')
        fill_in(labels[:markdown], with: 'Lorem Ipsum', id: 'competition_instructions_attributes_1_markdown')
        fill_in(labels[:markdown], with: 'Lorem Ipsum', id: 'competition_instructions_attributes_2_markdown')
        fill_in(labels[:markdown], with: 'Lorem Ipsum', id: 'competition_instructions_attributes_3_markdown')
        click_on("Criar Competição")
      end
    end

    # Ensure the competition was created
    page.assert_selector('div.notification.is-info', text: 'Competição criada com sucesso.', visible: true)
    page.assert_selector('span.title.is-4', text: competition_name, visible: true)

    assert_equal competition_path(Competition.last), page.current_path
  end

  test "An admin can't create an incomplete competition" do
    admin = create(:admin)

    # Sign in
    sign_in(admin)
    visit(competitions_path)

    # Look for create competition button
    assert(page.has_link?('Criar'))
    click_link('Criar')

    # Try to create without filling the form
    click_on("Criar Competição")

    # Ensure user return to the form
    page.assert_selector('h1.title', text: 'Nova Competição')
    page.assert_selector('span.help.is-danger', text: 'não pode ficar em branco')
  end

  test "An admin or general admin can disable a competition" do
    admin = create(:admin)
    competition = create(:competition)

    # Sign in
    sign_in(admin)
    visit(competitions_path)

    # page show competition
    visit(competition_path(competition))
    assert(page.has_link?('Desabilitar'))
    
    click_on("Desabilitar")

    # Ensure user return to the form
    page.assert_selector('div.notification.is-info', text: 'Competição desabilitada com sucesso.', visible: true)
    
    # page show competition
    visit(competition_path(competition))
    assert(page.has_link?('Habilitar'))
    
    click_on("Habilitar")
    # Ensure user return to the form
    page.assert_selector('div.notification.is-info', text: 'Competição habilitada com sucesso.', visible: true)
  end

  test "An general_admin can disable and enable a competition" do
    general_admin = create(:general_admin)
    competition = create(:competition)

    # Sign in
    sign_in(general_admin)
    visit(competitions_path)

    # page show competition
    visit(competition_path(competition))
    assert(page.has_link?('Desabilitar'))
    
    click_on("Desabilitar")

    # Ensure user return to the form
    page.assert_selector('div.notification.is-info', text: 'Competição desabilitada com sucesso.', visible: true)
    
    # page show competition
    visit(competition_path(competition))
    assert(page.has_link?('Habilitar'))
    
    click_on("Habilitar")
    # Ensure user return to the form
    page.assert_selector('div.notification.is-info', text: 'Competição habilitada com sucesso.', visible: true)
  end

  test "An user with common role can't disable and enable a competition" do
    user = create(:user)
    competition = create(:competition)

    # Sign in
    sign_in(user)
    visit(competitions_path)

    # page show competition
    visit(competition_path(competition))
    assert(page.has_no_link?('Desabilitar'))
    
  end
  
  test "An competition_admin can't disable and enable a competition" do
    competition_admin = create(:competition_admin)
    competition = create(:competition)

    # Sign in
    sign_in(competition_admin)
    visit(competitions_path)

    # page show competition
    visit(competition_path(competition))
    assert(page.has_no_link?('Desabilitar'))
    
  end 
end
