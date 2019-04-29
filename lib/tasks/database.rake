# Extend DB rake tasks

namespace :db do
  desc "Obscure data"
  task(:obfuscate  => :environment) do
    # ONLY NON PRODUCTION
    puts "Starting obfuscating task"
    puts "Checking environment allows obfuscation"
    if EY::Config.get(:base, :app_environment_name).split('/ ')[1].downcase != 'production'
      puts "Obfuscating data"
      puts "Obfuscating user details"
      User.all.each do |user|
        password = Faker::Lorem.characters(6)
        user.update_attributes(firstname: Faker::Name.first_name, 
                               lastname: Faker::Name.last_name,
                               email: Faker::Internet.email,
                               password: password,
                               password_confirmation: password)
      end

      puts "Obfuscating time sheet details"
      Timing.where('notes IS NOT NULL').update_all(notes: Faker::Lorem.sentence)

      puts "Obfuscating client details"
      Client.all.each do |client|
        client.update_attributes name: Faker::Company.name
      end

      puts "Obfuscating account details"
      # Account name e.g. account1.domain.com
      Account.all.each_with_index do |account, i|
        account.update_attributes site_address: "account#{ i }"
      end

      puts "Obfuscating project details"
      Project.all.each_with_index do |project, i|
        project.update_attributes name: "Project #{ i }", description: Faker::Lorem.sentence
      end

      ProjectComment.all.each do |project_comment|
        project_comment.update_attributes comment: Faker::Lorem.sentence
      end

      puts "Obfuscating team details"
      Team.all.each_with_index do |team, i|
        team.update_attributes name: "Team #{i}"
      end

      puts "Obfuscating phase details"
      Phase.all.each_with_index do |phase, i|
        phase.update_attributes name: "Phase #{i}"
      end

      puts "Obfuscating invoice details"
      Invoice.all.each do |invoice|
        invoice.update_attributes po_number: Faker::Number.number(6),
                                  address:   "#{ Faker::Address.street_address } #{ Faker::Address.city } #{ Faker::Address.postcode }",
                                  notes:     Faker::Lorem.sentence,
                                  email:     Faker::Internet.email
      end

      InvoiceItem.all.each do |invoice_item|
        invoice_item.update_attributes name: Faker::Commerce.product_name
      end

      PaymentProfile.all.each_with_index do |payment_profile, i|
        payment_profile.update_attributes name: "Payment profile #{ i }"
      end

      PaymentProfileRollover.all.each do |payment_profile_rollover|
        payment_profile_rollover.update_attributes reason_for_date_change: Faker::Lorem.sentence
      end

      puts "Obfuscating quote details"
      Quote.all.each_with_index do |quote, i|
        quote.update_attributes title: "Quote #{ i }", po_number: Faker::Number.number(6), extra_cost_title: quote.extra_cost_title ? Faker::Lorem.sentence : nil
      end

      QuoteSection.all.each do |quote_section|
        quote_section.update_attributes content: quote_section.content ? Faker::Lorem.sentence : nil
      end

      QuoteDefaultSection.all.each do |quote_default_section|
        quote_default_section.update_attributes content: quote_default_section.content ? Faker::Lorem.sentence : nil
      end

      puts "Deleting API and document data"
      OauthDriveToken.delete_all
      Document.delete_all
      DocumentComment.delete_all
      puts "Success"

      puts "Deleting private account data"
      AccountSetting.all.each do |as|
        as.update_attribute :invoice_alert_email, Faker::Internet.email
        as.update_attribute :schedule_mail_email, Faker::Internet.email
        as.update_attribute :expected_invoice_mail_email, Faker::Internet.email
        as.update_attribute :rollover_alert_email, Faker::Internet.email
        as.update_attribute :budget_warning_email, Faker::Internet.email
        as.update_attribute :stale_opportunity_email, Faker::Internet.email
        as.update_attribute :issue_tracker_username, nil
        as.update_attribute :issue_tracker_password, nil
        as.update_attribute :issue_tracker_url, nil
      end
    else
      puts "Failed: Cannot obfuscate data for this environment"
    end
  end
end

