require 'functional_dependency'

class FunctionalDependencySet
  attr_reader :functional_dependencies

  def initialize fds
    @functional_dependencies = fds.to_a.map do |determinant, dependent|
      FunctionalDependency.new determinant, dependent
    end
  end

  def closure
    return @closure if @closure

    set = Hash[functional_dependencies.map {|fd| [fd.determinant, fd.dependent]}]
    old = nil
    while set != old
      old = set.clone
      old.each do |det1, dep1|
        old.each do |det2, dep2|
          if det1 == det2
            next
          elsif det2 & (det1 + dep1) == det2
            set[det1] += dep2 - det1
            set[det1].sort!.uniq!
          else
            det = (det1 + det2 - dep1).sort.uniq
            set[det] ||= []
            set[det] += dep2 - det
            set[det].sort!.uniq!
          end
        end
      end
    end

    set = set.to_a
    old = nil
    while set != old
      old = set.clone
      old.each do |det1, dep1|
        implied = set.map do |det2, dep2|
          if det1 != det2 && det2 & det1 == det2
            dep2
          else
            []
          end
        end.flatten.sort.uniq

        if dep1 & implied == dep1
          set -= [[det1, dep1]]
        end
      end
    end

    @closure = FunctionalDependencySet.new set
  end

  def bcnf_violating_fd attributes, after_fd = nil
    closure.functional_dependencies.each do |fd|
      if attributes & (fd.determinant + fd.dependent) != attributes
        if after_fd.nil?
          return fd
        elsif after_fd.determinant == fd.determinant
          after_fd = nil
        end
      end
    end

    nil
  end

  def related_to attributes
    fds = functional_dependencies.select do |fd|
      fd.determinant + fd.dependent - attributes == []
    end.map do |fd|
      [fd.determinant, fd.dependent]
    end
  end

  def to_s
    functional_dependencies.map(&:to_s).join(' ; ')
  end

  def == other
    return false unless other.is_a?(FunctionalDependencySet)
    functional_dependencies.sort_by(&:to_s) == other.functional_dependencies.sort_by(&:to_s)
  end
end
