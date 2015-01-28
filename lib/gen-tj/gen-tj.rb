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
  
  def add_features features, flags = nil
    effortmap = { "*" => "3d",
                  "**" => "10d",
                  "***" => "4w",
                  "****" => "12w",
                  "S" => ["3d", ["mc","mantel"]],
                  "M" => ["10d", ["java1", "java2", "mc"]],
                  "L" => ["4w", ["java1", "java2"]],
                  "X" => ["12w", ["java1"]] }
    pos = 0
    features.each do |id|
      f = Feature.get(id)      
      raise "No feature #{id}" unless f
#      puts "#{id}:#{f.title}:"
      t = Task.new f.title, id
      pos += 1
      allocations = nil
      case f.title
      when /\[Manager ([x\d\.]+),\s*([SMLX\*])/
        t.effort, allocations = effortmap[$2] || ["2w", ["java1", "java2", "mc"]]
      else
        STDERR.puts "Feature #{id} not estimated >#{f.title}<"
        t.effort = "2w"
        allocations = ["mantel", "mc"]
      end
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
	t.allocations = allocations
      end

#      if relation.parent
#	t.add_relations relation, :noprio => true
#      end
      t.priority = pos unless flags && flags[:noprio]
      self.add t      
    end # relations.each
  end # def

end # class

module GenTJ
  class GenTJ
    private
    #
    # Extract named relationtree from keeper
    #
    # returns Array of feature #s
    #
    def _relationtree treename
      # get 'my' relationtree

      relationtree = Relationtree.first(:title => treename)
      unless relationtree
	STDERR.puts "No relationtree named '#{treename}' found"
      end
      relationtree.relations.map do |relation|
        relation.target.to_i
      end
    end
    #
    # Read list of features from file
    #
    # returns Array of feature #s
    #
    def _featurefile filename
      result = Array.new
      File.open(filename, "r") do |f|
        f.each do |l|
          if l =~ /^(\d+) /
            result << $1.to_i
          end
        end
      end
      result
    end
    public
    #
    # GenTJ.new
    #
    def initialize dir, args
      @dir = dir
      args.each do |key, val|
        case key
        when :treename then @treename = val
        when :prjname then @project = val
        when :featurefile then @featurefile = val
        else
          raise "Unrecognized arg #{key}"
        end
      end
      unless @project
        raise "Project name missing"
      end
      unless @treename || @featurefile
        raise "Must give either treename or featurefile"
      end
      if @treename && @featurefile
        raise "Must give either treename or featurefile, but not both"
      end
      DataMapper::Logger.new($stdout, :debug)
      keeper = DataMapper.setup(:default, :adapter => 'keeper', :url  => 'https://keeper.novell.com/sxkeeper')
      require 'keeper/feature'
      require 'keeper/relationtree'
      require 'keeper/relation'
      DataMapper.finalize
    end
    #
    # Generate tji with title
    #
    def generate title

      task = Task.new( title, @project )

      if @treename
        task.add_features(_relationtree @treename)
      else
        task.add_features(_featurefile @featurefile)
      end
      File.open(File.join(@dir, "#{@project}.tji"), "w+") do |f|
	f.puts task.to_tj
      end
    end
  end
end
