module Reports::ProjectsHelper

  def expected_invoice_amount_cents_for_period_helper(project, start_date, end_date, user_id = nil)
    result = project.expected_invoice_amount_cents_for_period(start_date, end_date, user_id)
    output = formated_in_default_currency(results * 100).to_s
    output << '*' if results[:contains_timings_without_rate_card]
    output
  end

  def expected_team_invoice_amount_cents_for_period_helper(team, start_date, end_date, user_id = nil)
    results = team.expected_invoice_amount_cents_for_period(start_date, end_date, user_id)
    output = formated_in_default_currency(results[:expected_invoice_amount] * 100).to_s
    output << '*' if results[:contains_timings_without_rate_card]
    output
  end

  def client_utilisation_project_comparison_helper(project, start_date, end_date)
    comparison = Invoice.amount_cents_invoiced_for_period_and_project(project.id, start_date, end_date) -
      project.expected_invoice_amount_cents_for_period(start_date, end_date)[:expected_invoice_amount] * 100

    comparison < 0 ? colour_class = :red_text : colour_class = :green_text

    content_tag :span, class: colour_class do
      formated_in_default_currency comparison
    end
  end

  def client_utilisation_project_team_comparison_helper(team, start_date, end_date)
    comparison = team.expected_invoice_amount_cents_for_period(start_date, end_date, nil)[:expected_invoice_amount] -
      team.total_invoice_amount(start_date, end_date)

    comparison < 0 ? colour_class = :red_text : colour_class = :green_text

    content_tag :span, class: colour_class do
      formated_in_default_currency comparison
    end
  end

end
