require 'test_helper'

class CompetitionTest < ActiveSupport::TestCase
  test 'It count the expected csv lines' do
    comp = create(:competition)
    assert_equal 11, comp.expected_csv_line_count

    comp.expected_csv = File.open(random_csv(100))
    comp.save
    assert_equal 100, comp.expected_csv_line_count

    comp.expected_csv = File.open(random_csv(42))
    comp.save
    assert_equal 42, comp.expected_csv_line_count
  end

  test 'It should disable a competition' do
    comp = create(:competition)
    comp.disable_visible
    assert_equal comp.visible, Competition.find(comp.id).visible   
  end

  test 'It should enable a competition' do
    comp = create(:competition)
    comp.enable_visible
    assert_equal comp.visible, Competition.find(comp.id).visible   
  end

end
