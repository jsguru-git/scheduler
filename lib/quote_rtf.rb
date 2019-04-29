class QuoteRTF

  include ActionView::Helpers::TextHelper
  include CustomCurrencyHelper
  include CustomDateTimeHelper

  attr_accessor :document, :quote, :project, :author

  def initialize(quote, project, author)
    @quote = quote
    @document = RTF::Document.new(RTF::Font.new(RTF::Font::ROMAN, 'Times New Roman'))
    @project = project
    @author = author

    titles
    quote.quote_sections.position_ordered.each_with_index do |section, index|
      section.cost_section? ? cost_section : default_section(section)
    end
  end

  def titles
    @document.paragraph << '\b ' + @quote.display_title
    @document.paragraph << '\b Estimate'
    @document.paragraph << '\b Prepared for ' + @project.client.name if project.client.present?
    @document.paragraph << '\b Author: ' + @author
    @document.paragraph << '\b ' + Time.now.to_s(:long)
    @document.paragraph << '\b Version ' + @quote.version_number
    @document.paragraph.line_break
  end

  def cost_section
    @document.paragraph << '\b Estimate'
    @document.paragraph.line_break

    table = document.table(@quote.quote_activities.size + 1, 3, 4000, 2000, 2000)
    table[0][0] << 'Task'
    table[0][1] << 'Time'
    table[0][2] << 'Cost ' + @quote.currency.upcase

    @quote.quote_activities.position_ordered.each_with_index do |quote_activity, i|

      # First column
      table[i + 1][0] << quote_activity.name

      # Second column
      if quote_activity.estimate_type == 0
        table[i + 1][1] << minute_duration_to_human_time(quote_activity.max_estimated_minutes, project.account, quote_activity.estimate_scale)
      else
        table[i + 1][1] << minute_duration_to_human_time(quote_activity.min_estimated_minutes, project.account, quote_activity.estimate_scale) + ' - ' + minute_duration_to_human_time(quote_activity.max_estimated_minutes, project.account, quote_activity.estimate_scale)
      end

      # Third column
      cost_column = ''
      if quote_activity.discount_percentage.present? && quote_activity.discount_percentage != 0.0
        cost_column << '(Incl ' + quote_activity.discount_percentage_out + '% discount)'
      end
      if quote_activity.estimate_type == 1
        cost_column << formated_in_default_currency(quote_activity.min_amount_cents_in_report_currency) + ' - '
      end
      cost_column << formated_in_default_currency(quote_activity.max_amount_cents_in_report_currency)

      table[i + 1][2] << cost_column
    end

    @document.paragraph.line_break
    cost_summary
  end

  def cost_summary
    unless @quote.extra_cost_cents.zero?
      @document.paragraph << @quote.extra_cost_title + ': ' + formated_in_provided_currency(@quote.extra_cost_cents_in_report_currency, @quote.currency)
    end

    subtotal = ''
    if @quote.include_range_estimates?
      subtotal << formated_in_provided_currency(@quote.total_min_cost_excl_discount_and_vat_cents_in_report_currency, @quote.currency) + ' - '
    end
    subtotal << formated_in_provided_currency(@quote.total_max_cost_excl_discount_and_vat_cents_in_report_currency, @quote.currency)
    @document.paragraph << "Subtotal: #{ subtotal }"

    if @quote.discount_percentage != 0
      @document.paragraph << "Discount: #{ @quote.discount_percentage_out } %"
    end

    @document.paragraph << "Tax: #{ @quote.vat_rate_out } %"

    total = ''
    if @quote.include_range_estimates?
      total << formated_in_provided_currency(@quote.total_min_cost_incl_discount_and_vat_cents_in_report_currency, @quote.currency) + ' - '
    end
    total << formated_in_provided_currency(@quote.total_max_cost_incl_discount_and_vat_cents_in_report_currency, @quote.currency)
    @document.paragraph << "Total: #{ total }"
  end

  def default_section(section)
    @document.paragraph.bold << section.title
    @document.paragraph.line_break
    simple_format(section.content).split('<br />').each do |p|
      @document.paragraph << strip_tags(p)
    end

    @document.paragraph.line_break
  end

  def to_rtf
    @document.to_rtf
  end
end