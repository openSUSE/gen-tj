#
# Generate TJ resources from YAML file + present.suse.de:9874
#

require 'yaml'
require 'net/telnet'

RESOURCES = "resources.yml"

# => {"dmacvicar"=>"Duncan Mac-Vicar", "ncc"=>"NCC", "qa"=>{"_name"=>"product qa", "mseidl"=>"Martin Seidl"}, "docu"=>{"_name"=>"Doku", "ke"=>"Karl Eichwalder"}, "kkaempf"=>"Klaus K\303\244mpf", "dev"=>{"mc"=>"Michael Calmer", "iartarisi"=>"Ionu\310\233 C. Ar\310\233\304\203ri\310\231i", "_name"=>"Developers", "mantel"=>"Hubert Mantel", "java"=>{"jrenner"=>"Johannes Renner", "_name"=>"Java guys", "bmaryniuk"=>"Bo Maryniuk"}, "ug"=>"Uwe Gansert", "ma"=>"Michael Andres"}}

def create_vacations name, to
  tn = Net::Telnet.new('Host' => 'present.suse.de', 'Port' => 9874, 'Binmode' => true)
  collect = false
  tn.cmd(name) do |data|
#    STDERR.puts "<#{name}> -> #{data}"
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
	next unless date =~ /2011/
	dates << date
      end
      case dates.size
      when 1: to.puts "  vacation #{dates[0]}"
      when 2: to.puts "  vacation #{dates[0]} - #{dates[1]}"
      else
	STDERR.puts "#{dates.size} dates for (#{name}) '#{l}'"
      end
    end
  end
  tn.close
end

def create_tj resources, to
  resources.each do |key, value|
    next if key == "_name"
    name = value.is_a?(String) ? value : value['_name']
    to.puts "resource #{key} #{name.inspect} {"
    case value
    when String: create_vacations name, to
    when Hash
      create_tj value, to
      to.puts "flags team"
    else
      raise "Can't handle #{value.class} for #{key}"
    end
    to.puts "}"
  end

end

resources = YAML::load(File.open( ARGV.shift || RESOURCES))

out = File.open(ARGV.shift, "w") rescue STDOUT

out.puts "flags team"
create_tj resources, out
