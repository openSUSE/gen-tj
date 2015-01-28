#
# Class representing a task (aka Fate feature)
#
class Task
  attr_reader :title, :effort, :duration, :status
  attr_accessor :allocations

  def initialize(title, fate = nil)
    @title = title
    @fate = fate
    @allocations = []
    @@started = false
  end

  def add task
    @subtasks ||= []
    @subtasks << task
  end

  def priority= prio
    @priority = prio.to_i
  end

  def effort= eff
    @effort = eff
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
      pos = 0
      @allocations.each do |rsrc|
        if pos == 0
          s << "    allocate #{rsrc} {"
        else
          if pos == 1
            s << " select order"
          end
          s << " alternative #{rsrc}"
        end
        pos += 1
      end
      s << "}\n"
      s << "    duration #{duration}\n" if @duration
      s << "    effort #{effort}\n" if @effort
    end
    s << "}\n"
    
    s
  end
end
