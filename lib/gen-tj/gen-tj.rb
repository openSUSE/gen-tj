#
# gentj.rb
#
# Generate TaskJuggler tasks from Fate relation tree
#
# Usage:
#   ruby gentj.rb <relation-tree-title> <tji-name>
# Example:
#   ruby gentj.rb "Project tree" project
#  -> generates 'project.tji' file
#

require 'rubygems'
require 'dm-bugzilla-adapter'
require 'dm-keeper-adapter'
require 'nokogiri'
require File.join(File.dirname(__FILE__),'task')

class Task
  
  def add_relations relations, flags = nil
    relations.each do |relation|
      id = relation.target
      f = Feature.get(id)
      
      unless f.milestone =~ /^1\.2/
	STDERR.puts "Skipping feature #{id} with milestone '#{f.milestone}'"
	next
      end

      raise "No feature #{id}" unless f
      prio = relation.sort_position
      t = Task.new f.title, id
      case f.developer
      when /<email.*>/
	alloc = Nokogiri.XML "<alloc>#{f.developer}</alloc>"
	alloc.xpath("//email").each do |mail|
	  mail.text =~ /(.*)@(.*)/
	  t.allocations << $1
	end
      when /(.*)@(.*)/
	t.allocations << $1
      else
	t.allocations << "dev"
      end

      if relation.parent
	t.add_relations relation, :noprio => true
      end
      t.priority = prio unless flags && flags[:noprio]
      
      self.add t
    end # relations.each
  end # def

end # class

module GenTJ
  class GenTJ
    def GenTJ.main dir, treename, subtitle
      DataMapper::Logger.new($stdout, :debug)
      keeper = DataMapper.setup(:default, :adapter => 'keeper', :url  => 'https://keeper.novell.com/sxkeeper')
      require 'keeper/feature'
      require 'keeper/relationtree'
      require 'keeper/relation'
      DataMapper.finalize

      # get 'my' relationtree

      relationtree = Relationtree.first(:title => treename)

      title = relationtree.title

      task = Task.new(title,subtitle)

      task.add_relations(relationtree.relations)

      File.open(File.join(dir,"#{subtitle}.tji"), "w+") do |f|
	f.puts task.to_tj
      end
    end
  end
end
