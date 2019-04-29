desc 'Create YAML test fixtures from data in an existing database.
Defaults to development database.  Set RAILS_ENV to override.'

task :extract_fixtures => :environment do
  puts 'Starting extract'
    sql  = "SELECT * FROM %s ORDER BY id LIMIT 10"
    alt_sql  = "SELECT * FROM %s LIMIT 10"
    #skip_tables = ["schema_info"]
    tables_to_process = ["qa_stats"]
    ActiveRecord::Base.establish_connection
     #(ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
    tables_to_process.each do |table_name|
      puts "Extracting #{table_name}"
        i = "000"
        File.open("#{Rails.root}/test/fixtures/#{table_name}.yml", 'w') do |file|
            data = []
            begin
                data = ActiveRecord::Base.connection.select_all(sql % table_name)
            rescue
                data = ActiveRecord::Base.connection.select_all(alt_sql % table_name)
            end
            file.write data.inject({}) { |hash, record|
                hash["#{table_name}_#{i.succ!}"] = record
                hash
            }.to_yaml
        end
    end
end
