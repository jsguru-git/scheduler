# encoding: utf-8

require 'test_helper'

class InvoicePdfTest < ActiveSupport::TestCase

  def setup
    @invoice = invoices(:invoices_001)
    @pdf = InvoicePdf.new(@invoice)
  end

  test "grey should return the correct color" do
    assert_equal "555555", @pdf.grey
  end

  test "black should return the correct color" do
    assert_equal "111111", @pdf.black
  end

  test "should normalize string lengths" do
    actual = @pdf.normalize_string_lengths(["one", "four", "eleven"])
    expected = ["   one", "  four", "eleven"]
    assert_equal expected, actual
  end
end
