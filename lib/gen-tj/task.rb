#
# Class representing a task (aka Fate feature)
#
class Task
  attr_reader :title, :effort, :duration, :status
  attr_accessor :allocations

  def initialize(title, fate = nil)
    # title = '[manager , ***] blah blah'
    if title =~ /\[(.*)\](.*)/
      # $1 = full match, i.e. '[manager , ***, D] blah blah'
      # $2 = sub match, i.e 'manager, ***, D'
      @title = $2.strip
      if $1 =~ /(.*),(.*)[,(.*)]?/
	case $2.strip
	when "*"
          @effort = "2d"
	when "**"
          @effort = "1w"
	when "***"
          @effort = "2w"
	when "****"
          @effort = "4w"
	else
	  @effort = $2
	end
	if $3 && $3 == "D"
	  @status = :done
	end
      end
    else
      @title = title 
    end
    @fate = fate
    @allocations = []
  end
  
  def add task
    @subtasks ||= []
    @subtasks << task
  end
  
  def priority= prio
    @priority = prio.to_i
  end

  #
  # Convert Task to tj
  #
  def to_tj
    s = "task "
    if @fate
      s << "fate_#{@fate}"
    else
      s << "task_#{self}"
    end
    t = @title.tr("\"", "'")
    s << " \"#{t}\" {\n"
    s << "  priority #{900-@priority}\n" if @priority
    s << "  start ${now}\n"
    if @subtasks
      @subtasks.each do |task|
	s << task.to_tj
      end
    else
      if @allocations.size == 1
	s << "    allocate #{allocations[0]}\n"
      else
	@allocations.each do |rsrc|
	  s << "    allocate #{rsrc} { mandatory }\n"
	end
      end
	
      s << "    duration #{duration}\n" if @duration
      s << "    effort #{effort}\n" if @effort
    end
    s << "}\n"
    
    s
  end
end
