#
# crosscheck.rb
#
# Crosscheck if features are in relationtree
#
# Usage: crosscheck "<match>"
#
# Example: ruby crosscheck.rb "Manager 1.2.1"
#
# <match> must exist in feature title _and_ name of relation tree
#
#

$: << File.join(File.dirname(__FILE__), "..", "dm-keeper-adapter", "lib")

require 'rubygems'
require 'dm-keeper-adapter'
require 'nokogiri'

title = (ARGV.shift || "Manager 1.2.1")

STDERR.puts "Checking '#{title}'"

DataMapper::Logger.new($stdout, :debug)
keeper = DataMapper.setup(:default, :adapter   => 'keeper',
			    :url  => 'https://keeper.novell.com/sxkeeper')
require 'keeper/feature'
require 'keeper/relationtree'
require 'keeper/relation'
DataMapper.finalize

# Get all features with a matching title

features = Feature.all(:title.like => title)

STDERR.puts "No features matching '#{title}' found" unless features && features.size>0

# Get the corresponding relationtree
relationtree = Relationtree.first(:title => title)

# Now iterate through the relationtree and remove matching features

relationtree.relations.each do |relation|
  target = relation.target
  size_of_relation_tree += 1
  t_id = target.to_i
  if features.delete(t_id).nil?
    puts "Target #{t_id} has bad title"
  end
end

STDERR.puts "No relation tree matching '#{title}' found" if size_of_relation_tree == 0

# Print out left over features

features.each do |id|
  puts "Feature #{id} is not in relation tree"
end
