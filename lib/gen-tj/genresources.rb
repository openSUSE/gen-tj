#encoding: UTF-8
#
# Generate TJ resources from YAML file + present.suse.de:9874
#

require 'yaml'
require 'net/telnet'

module GenTJ
  Encoding.default_external = "UTF-8"
  class Genresources

    #
    # Create vacations entry for 'name', write to 'to'
    #
    #  Use present.suse.de:9874 to extract dates
    #
    def Genresources.create_vacations name, to
      tn = Net::Telnet.new('Host' => 'present.suse.de', 'Port' => 9874, 'Binmode' => false)
      collect = false
      tn.cmd(name) do |data|
	    STDERR.puts "<#{name}> -> #{data}"
	data.split("\n").each do |l|
	  if l =~ /^Absence/
	    collect = true
	  end
	  next unless collect
	  if l[0,1] == "-"
	    collect = false
	    next
	  end
	  dates = []
	  l.split(" ").each do |date|
	    next unless date =~ /2013|2014|2015|2016/
	    dates << date
	  end
	  case dates.size
	  when 1
            to.puts "  vacation #{dates[0]}"
	  when 2
            to.puts "  vacation #{dates[0]} - #{dates[1]}"
	  else
	    STDERR.puts "#{dates.size} dates for (#{name}) '#{l}'"
	  end
	end
      end
      tn.close
    end

    #
    # Create taskjuggler 'resource' entry for login, write to 'to'
    #
    # 'value' is either a string (name of resource)
    #  or a Hash (denoting a team)
    #
    def Genresources.create_tj login, value, to
      return if login == "_name"
      name = value.is_a?(String) ? value : value['_name']
      raise "Resource #{login} has no name" unless name
      to.puts "resource #{login} #{name.inspect} {"
      case value
      when String
        create_vacations name, to
      when Hash
	value.each do |k,v|
	  create_tj k, v, to
	  to.puts "flags team"
	end
      else
	raise "Can't handle #{value.class} for #{login}"
      end
      to.puts "}"
    end

    def Genresources.run input, output = nil
      resources = YAML::load(File.open( input ))

      out = File.open(output) rescue STDOUT

      out.puts "flags team"
      resources.each do |login, value|
	create_tj login, value, out
      end
    end
  end
end
