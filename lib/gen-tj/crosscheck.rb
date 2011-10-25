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
    def Crosscheck.run title, reftree

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
	features[f.id.to_i] = f
#	puts "Feature #{f.id}:#{f.title}"
      end

      unless features.size>0
	STDERR.puts "No features matching '#{title}' found" 
	return
      end

      # Get the corresponding relationtrees
      relationtrees = Relationtree.all(:title.like => reftree)

      unless relationtrees
	STDERR.puts "No relationtree matching '#{reftree}' found" 
	return
      end

      # Now iterate through the relationtrees and remove matching features

      deleted = {}
      relationtrees.each do |relationtree|
	size_of_relation_tree = 0
	puts "Checking tree '#{relationtree.title}'"
	relationtree.relations.each do |relation|
#	  puts "-> #{relation.inspect}"
	  target = relation.target
	  size_of_relation_tree += 1
	  t_id = target.to_i
#	  puts "-> #{t_id}"
	  if features.delete(t_id).nil?
	    deltree = deleted[t_id]
	    if deltree
	      puts "#{t_id} is in '#{relationtree.title}' and '#{deltree.title}'"
	    else
	      puts "#{t_id} is weird"
	    end
	  end
	  deleted[t_id] ||= relationtree
	end
	if size_of_relation_tree == 0
	  STDERR.puts "Relationtree '#{title}' has no features"
	end
      end

      # Print out left over features

      features.each do |id,f|
	next if f.done
	next if f.rejected
	next if f.duplicate
	puts "Missing in relation tree - #{id}:#{f.done}'#{f.title}'"
      end
    end
  end
end