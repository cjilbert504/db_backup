#!/usr/bin/env ruby

# Bring OptionParser in
require "optparse"
# Bring in English - which allows access to global variables via less cryptic names
require "English"
# Bring in Open3 to provide access to the standard error stream
require "open3"

options = {}
option_parser = OptionParser.new do |opts|
  executable_name = File.basename $PROGRAM_NAME
  opts.banner = <<~BANNER
    Backup one or more MySQL databases

    Usage: #{executable_name} [options] database_name

  BANNER

  # Create a switch
  opts.on "-i", "--end-of-iteration", "Indicate that this backup is an 'iteration' backup" do
    options[:iteration] = true
  end

  # Create a flag
  opts.on "-u USER", "--username", "Database username, in first.last format", /^.+\..+$/ do |user|
    options[:user] = user
  end

  opts.on "-p PASSWORD", "--password", "Database password" do |password|
    options[:password] = password
  end

  opts.on "--no-gzip", "Do not compress the backup file" do
    options[:gzip] = false
  end

  opts.on "--[no-]force", "Overwrite existing files" do |force|
    options[:force] = true
  end
end

exit_status = 0
begin
  option_parser.parse!
  # puts options.inspect
  if ARGV.empty?
    puts "error: you must supply a database_name"
    puts
    puts option_parser.help
    exit_status |= 0b0010
  end
rescue OptionParser::InvalidArgument => ex
  puts ex.message
  puts option_parser
  exit_status |= 0b0001
end

auth = ""
auth += "-u#{options[:user]} " if options[:user]
auth += "-p#{options[:password]} " if options[:password]

database_name = ARGV[0]
output_file = "#{database_name}.sql"

command = "mysqldump #{auth}#{database_name} > #{output_file}"

if File.exists? output_file
  if options[:force]
    STDERR.puts "Overwriting #{output_file}"
  else
    STDERR.puts "error: #{output_file} exists, use --force to overwrite"
    exit 1
  end
end

puts "Running '#{command}'"
stdout_str, stderr_str, status = Open3.capture3(command)

Signal.trap "SIGINT" do
  FileUtils.rm output_file
  exit 1
end

unless status.exitstatus == 0
  STDERR.puts "There was a problem running '#{command}'"
  STDERR.puts stderr_str.gsub(/^mysqldump: /, "")
  exit 1
end
