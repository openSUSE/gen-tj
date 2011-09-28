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

module GenTJ
  class Crosscheck
    def Crosscheck.run title

      DataMapper::Logger.new($stdout, :debug)
      keeper = DataMapper.setup(:default, :adapter   => 'keeper',
			    :url  => 'https://keeper.novell.com/sxkeeper')
      require 'keeper/feature'
      require 'keeper/relationtree'
      require 'keeper/relation'
      DataMapper.finalize

      # Get all features with a matching title

      features = {}
      Feature.all(:title.like => title).each do |f|
	features[f.id] = f
      end

      unless features.size>0
	STDERR.puts "No features matching '#{title}' found" 
	return
      end

      # Get the corresponding relationtree
      relationtree = Relationtree.first(:title.like => title)

      unless relationtree
	STDERR.puts "No relationtree matching '#{title}' found" 
	return
      end

      # Now iterate through the relationtree and remove matching features

      size_of_relation_tree = 0
      relationtree.relations.each do |relation|
	target = relation.target
	size_of_relation_tree += 1
	t_id = target.to_i
	if features.delete(t_id).nil?
	  puts "Target #{t_id} has a bad title"
	end
      end

      if size_of_relation_tree == 0
	STDERR.puts "Relationtree '#{title}' has no features"
	return
      end

      # Print out left over features

      features.each do |id,f|
	puts "Missing in relation tree - #{id}:'#{f.title}'"
      end
    end
  end
end