require 'functional_dependency'

class FunctionalDependencySet
  attr_reader :functional_dependencies

  def initialize fds
    @functional_dependencies = fds.to_a.map do |determinant, dependent|
      FunctionalDependency.new determinant, dependent
    end
  end

  def closure
    set = Hash[functional_dependencies.map {|fd| [fd.determinant, fd.dependent]}]
    old = nil

    while set != old
      old = set
      old.each do |det1, dep1|
        old.each do |det2, dep2|
          if det2 & (det1 + dep1) == det2
            set[det1] = (dep1 + dep2 - det1).sort.uniq
          end
        end
      end
    end

    FunctionalDependencySet.new set
  end

  def bcnf_violating_fd attributes
    closure.functional_dependencies.each do |fd|
      if attributes & (fd.determinant + fd.dependent) != attributes
        return fd
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
    functional_dependencies.map(&:to_s).join(', ')
  end

  def == other
    return false unless other.is_a?(FunctionalDependencySet)
    functional_dependencies == other.functional_dependencies
  end
end
