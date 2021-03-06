MYSQL = ENV['DB_BACKUP_MYSQL'] || '/usr/local/bin/mysql'
USER = ENV['DB_BACKUP_USER'] || 'root'

Given /^the database backup_test exists$/ do
  test_sql_file = File.join(File.dirname(__FILE__), "..", "..", "setup_test.sql")
  command = "#{MYSQL} -u#{USER} < #{test_sql_file}"
  stdout, stderr, status = Open3.capture3(command)
  unless status.success?
    raise "Problem running #{command}, stderr was:\n#{stderr}"
  end
end

def expected_filename
  now = Time.now
  sprintf("backup_test-%4d-%02d-%02d.sql", now.year, now.month, now.day)
end

Then /^the backup file should be gzipped$/ do
  step %(a file named "#{expected_filename}.gz" should exist)
end

Then /^the backup file should NOT be gzipped$/ do
  now = Time.now
  step %(a file named "#{expected_filename}" should exist)
end
