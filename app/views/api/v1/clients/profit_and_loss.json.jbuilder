day_rate = @client.avg_rate_card_amount_cents.round(2)
mins_tracked = Timing.minute_duration_submitted_for_period_and_client(@client.id, @start_date, @end_date)
invoiced_amount = Invoice.amount_cents_invoiced_for_period_and_client(@client.id, @start_date, @end_date).round(2)
days_tracked = (hours = mins_tracked.to_s.to_d / @client.account.account_setting.working_day_duration_minutes).round(2)
p_l_days = (days_tracked - (invoiced_amount/day_rate.to_s.to_d)).round(2)
p_l_cost = (invoiced_amount - (days_tracked*day_rate.to_s.to_d)).round(2)

if invoiced_amount == 0 && days_tracked != 0
  p_l_percent = -100
elsif invoiced_amount != 0 && days_tracked == 0
    p_l_percent = 100
elsif invoiced_amount == 0
  p_l_percent = 0
else
  p_l_percent = ((p_l_cost/invoiced_amount)*100).round(2)
end

total_project_potential = (days_tracked*day_rate).round(2)

if invoiced_amount == 0 && days_tracked != 0
  day_rate_after_p_l = 0
elsif invoiced_amount != 0 && days_tracked == 0
  day_rate_after_p_l = invoiced_amount
elsif invoiced_amount == 0
  day_rate_after_p_l = day_rate
else
  day_rate_after_p_l = ((invoiced_amount/total_project_potential)*day_rate).round(2)
end

json.average_day_rate 			day_rate
json.tracked_days 	 			days_tracked
json.amount_invoiced 			invoiced_amount
json.profit_and_loss_days 		p_l_days
json.profit_and_loss_cost 		p_l_cost
json.profit_and_loss_percent 	p_l_percent
json.profit_and_loss_day_rate 	day_rate_after_p_l