FactoryGirl.define do

  factory :invoice do
    invoice_date Date.today
    due_on_date Date.today
    sequence :invoice_number do |n|
      500 + n
    end
    currency 'gbp'
    pre_payment false
    vat_rate 20

    project
  end

end