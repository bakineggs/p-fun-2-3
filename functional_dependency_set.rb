require 'functional_dependency'

class FunctionalDependencySet
  attr_reader :functional_dependencies

  def initialize fds
    @functional_dependencies = fds.to_a.map do |determinant, dependent|
      FunctionalDependency.new determinant, dependent
    end
  end

  def closure
    self
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
