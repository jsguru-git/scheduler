# ==============================================
#
# PDF for Invoice Generation
#
# ==============================================

require 'utils'

# This module contains most of the default settings and styles
# for the invoice typography
#
module PDFSettings
  FONT_TYPES =
    { intro: { size: 36, style: :bold, leading: 0 },
      invoice_heading: { size: 34, leading: 0, style: :bold },
      h1: { size: 24, leading: 10, style: :bold },
      h2: { size: 20, leading: 10, style: :bold },
      h3: { size: 14, leading: 10, style: :bold },
      h4: { size: 12, leading: 10, style: :bold },
      h4_align_right: { size: 12, leading: 10, style: :bold, align: :right },
      h5: { size: 12, leading: 3,  align: :right },
      sub_heading: { size: 24, leading: 4 },
      default: { size: 11, leading: 3 },
      footer: { size: 10, leading: 4 } }

  SETTINGS = {
    fonts: FONT_TYPES
  }

  COLORS = {
    grey: '555555',
    black: '111111'
  }
end

class InvoicePdf < Prawn::Document

  include PDFSettings

  # Initialize the class

  def initialize(invoice, args = {})
    super(margins)
    @invoice = invoice
    @options = args
    fill_color grey
    dispatch
  end

  # Utility methods
  # ***************************************************************

  def grey
    COLORS[:grey]
  end

  def black
    COLORS[:black]
  end

  # Sets the document fonts and include Arial
  def set_fonts
    font_families.update("Arial" => {
       :normal => "#{Rails.root}/vendor/assets/fonts/Arial.ttf",
       :bold => "#{Rails.root}/vendor/assets/fonts/Arial-Bold.ttf"
     })
    font "Arial"
  end

  def margins
    { top_margin: 25, left_margin: 50, right_margin: 50, bottom_margin: 25 }
  end

  # Code executed within a block passed to this function will have a given color
  def with_color(color="999999", &block)
    fill_color color
    yield if block_given?
    # Reset the color to the default
    fill_color grey
  end

  def with_font(font, &block)
    if [:h1, :h2, :h3, :h4, :h5, :invoice_heading].include?(font)
      fill_color "111111"
    end
    t = block.call()
    text t, SETTINGS[:fonts][font]
    fill_color grey
  end

  def half_width
    bounds.width / 2
  end

  def grid_width
    bounds.width / 12
  end

  def left_width
    grid_width * 8
  end

  def right_width
    grid_width * 4
  end

  def left_relative offset, &block
    bounding_box([bounds.left, offset], :width => left_width) do
      yield
    end
  end

  def right_relative offset, &block
    bounding_box([bounds.right - right_width, offset], :width => right_width) do
      yield
    end
  end

  def left_col offset, &block
    bounding_box(
      [bounds.left, bounds.top - offset], :width => left_width
    ) do
      yield
    end
  end

  # Render and yield text inside a right column
  def right_col offset, &block
    bounding_box(
      [bounds.right-right_width, bounds.top - offset], :width => right_width
    ) do
      yield
    end
  end

  def vat_to_string(bool)
    bool ? "YES" : "NO"
  end

  def alternating_color_text(text1, color1, text2, color2, size=15)
    "<font size=\"#{size}\">" +
      "<color rgb=\"#{color1}\">#{text1}</color>" +
      "<color rgb=\"#{color2}\">#{text2}</color>" +
    "</font>"
  end

  # ***************************************************************

  # Logo placement
  def logo
    if @invoice.project.account.account_setting.logo_file_name
      left_col 0 do
        image open(ApplicationController.helpers.s3_image(@invoice.project.account.account_setting.logo(:normal), { protocol: @options[:protocol] }))
      end
    end
  end

  # The main method that renders the various page components
  def dispatch
    logo
    billing_info
    invoice_info
    heading
    line_items
    invoice_summary
  end

  # The top left billing info column
  def billing_info
    left_col 0 do
      move_down(120) if @invoice.project.account.account_setting.logo_file_name
      if @invoice.address.present?
        with_font :h3, &->{ "Bill to:" }
        with_font :default, &->{ @invoice.address }
      end
      if @invoice.email.present?
        move_down(10) if @invoice.address.present?
        with_font :default, &->{ @invoice.email }
      end
    end
  end

  def alternating_text(x, y)
    text alternating_color_text(x, "111111", y, grey, 11), :inline_format => true, :align => :right
    move_down 2
  end

  # The top right invoice information column
  def invoice_info
    right_col 0 do
      alternating_text("Inv Date: ", "#{Utils::Date.humanize(@invoice.invoice_date)}")
      alternating_text("Due Date: ",  "#{Utils::Date.humanize(@invoice.due_on_date)}")
      alternating_text("Invoice No: ", "#{@invoice.invoice_number}")
      alternating_text("Terms: ", "#{@invoice.terms}")
      alternating_text("Po No: ", "#{@invoice.po_number}")
      alternating_text("Pre Payment: ", "#{@invoice.pre_payment ? "Yes" : "No"}")
      alternating_text("Currency: ", "#{@invoice.currency.upcase}")
    end
  end

  # Renders the invoice heading which contains the invoice ID
  def heading
    @invoice.project.account.account_setting.logo_file_name ? move_down(220) : move_down(100)

    formatted_text([
      { :text => "Invoice",
        :color => "111111",
        :size => 35,
        :style => [:bold]
      },
      { :text => " #{@invoice.invoice_number}",
        :color => "999999",
        :size => 35,
        :style => [:bold]
      }
    ])
    move_down 20
  end

  # Tables
  # ***************************************************************

  # Headers for the PDF line items table
  def table_headers
    ["Description", "Qty", "VAT", "Amount"]
  end

  # Format the item amount cents to show currency symbol
  def format_item_amount(item)
    Money.new(item.amount_cents, @invoice.currency).format(
      :no_cents_if_whole => false
    )
  end

  # Returns line item data as a matrix for table insertion
  def line_item_data
    items = @invoice.invoice_items.collect do |item|
      [item.name, item.quantity, vat_to_string(item.vat), format_item_amount(item)]
    end
    items.unshift(table_headers)
  end

  def table_style
    { size: 11, border_color: "FFFFFF", border_width: 1, borders: [:bottom] }
  end

  # Lines items PDF table
  def line_items
    move_down 20
    data = line_item_data
    options = { width: bounds.width }
    header_styles = {
      border_width: 2,
      border_color: "333333"
    }
    table data, options do |table|
      table.rows(0).style(table_style.merge(header_styles))
      table.rows(1).style(table_style.merge(padding_top: 30))
      table.rows(2..data.length-1).style(table_style)
    end
    move_down 10
    stroke_color "999999"
    stroke_horizontal_rule
  end

  # Bottom section
  # ***************************************************************

  def payment_and_notes
    if @invoice.payment_methods.present?
      with_font :h4, &->{ "Payment Methods" }
      with_color "AAAAAA" do
        with_font :default, &->{ @invoice.payment_methods }
      end
    end
    move_down 20 if @invoice.payment_methods.present?
    if @invoice.notes.present?
      with_font :h4, &->{ "Notes" }
      with_color "AAAAAA" do
        with_font :default, &->{ @invoice.notes }
      end
    end
  end

  def total_amount_with_vat
    @invoice.total_amount_inc_vat_in_currency
  end

  def total_amount_without_vat
    @invoice.total_amount_exc_vat_in_currency
  end

  def invoice_total_text(x, c1, y, c2)
    text alternating_color_text(x, c1, y, c2),
      :inline_format => true,
      :align => :right
    move_down 5
  end

  # Given a sequence of strings, normalize them so they are
  # all the same length by prepending whitespace to the front
  def normalize_string_lengths(arr)
    max = arr.map(&:length).max
    arr.map { |str| len = str.length; (" " * (max - len)) + str }
  end

  def invoice_totals
    c1 = "999999"
    c2 = "111111"
    sub_total = "   #{total_amount_without_vat}"
    vat = "   #{@invoice.vat_rate.to_f}%"
    total = "   #{total_amount_with_vat}"
    normalized = normalize_string_lengths([sub_total, vat, total])
    invoice_total_text("Subtotal:", c1, normalized[0], c2)
    invoice_total_text("VAT: ", c1, normalized[1], c2)
    invoice_total_text("Total:", c2, normalized[2], c2)
    move_down 40
  end

  def invoice_summary
    move_down 40
    invoice_totals
    payment_and_notes
  end
end

