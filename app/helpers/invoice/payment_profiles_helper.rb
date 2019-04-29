module Invoice::PaymentProfilesHelper
  
  # Descides if a check box should have a blank field.
  def should_show_blank_rate_card_option?(rate_card_select)
    if rate_card_select.object.new_record?
      true
    else
      false
    end
  end
  
  # Return the currently saved month of the given instance
  def data_attr_for_ori_month(instance)
    if instance.expected_payment_date_changed?
      instance.changes[:expected_payment_date][0].month
    else
      instance.expected_payment_date.month
    end
  end
  
  # Return the currently saved year of the given instance
  def data_attr_for_ori_year(instance)
    if instance.expected_payment_date_changed?
      instance.changes[:expected_payment_date][0].year
    else
      instance.expected_payment_date.year
    end
  end
  
end
