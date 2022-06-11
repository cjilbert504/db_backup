#!/usr/bin/env ruby

class Dog
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

# Bring OptionParser in
require "optparse"

options = {}
option_parser = OptionParser.new do |opts|

  opts.accept(Dog) do |name|
    Dog.new(name)
  end

  # Create a switch
  opts.on "-i", "--iteration" do
    options[:iteration] = true
  end

  # Create a flag
  opts.on "-u USER", /^.+\..+$/ do |user|
    options[:user] = user
  end

  # Example command-line usage:
  # ruby db_backup/bin/db_backup_initial.rb -u Bob.bob -p McGruff
  # puts options.inspect
  # => {:user=>"Bob.bob", :password=>#<Dog:0x00007ff389823f78 @name="McGruff">}
  opts.on "-p PASSWORD", Dog do |password|
    options[:password] = password
  end
end

option_parser.parse!
puts options.inspect

# database = ARGV.shift
# username = ARGV.shift
# password = ARGV.shift
# end_of_iter = ARGV.shift

# if end_of_iter.nil?
#   backup_file = database + Time.now.strftime "%Y%m%d"
# else
#   backup_file = database + end_of_iter
# end

# `mysqldump -u#{username} -p#{password} #{database} > #{backup_file}.sql`
# `gzip #{backup_file}.sql`
# end
