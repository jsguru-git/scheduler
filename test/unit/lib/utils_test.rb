#coding: utf-8

require 'test_helper'
require 'utils'

class UtilsTest < ActiveSupport::TestCase

  def test_money_returns_symbol_as_string
    actual = Utils::Currency.symbol(:gbp)
    assert_equal "£", actual
  end

  def test_format_date_returns_humand_readable_format
    date = DateTime.new(2013, 12, 12)
    actual = Utils::Date.humanize(date)
    expected = "December 12, 2013"
    assert_equal expected, actual
  end
end

