require 'functional_dependency'

class FunctionalDependencySet
  attr_reader :functional_dependencies

  def initialize fds
    @functional_dependencies = fds.to_a.map do |determinant, dependent|
      FunctionalDependency.new determinant, dependent
    end
  end

  def closure attributes
    closure = attributes.chars.sort.uniq

    old = nil
    until old == closure
      old = closure
      functional_dependencies.each do |fd|
        if fd.determinant & closure == fd.determinant
          closure = (closure + fd.dependent).sort.uniq
        end
      end
    end

    closure.join('')
  end

  def bcnf_violating_fd attributes
    functional_dependencies.each do |fd|
      if closure(fd.determinant.join('')).chars.to_a & attributes != attributes
        return fd
      end
    end

    nil
  end

  def related_to attributes
    fds = functional_dependencies.select do |fd|
      fd.determinant + fd.dependent - attributes == []
    end.map do |fd|
      [fd.determinant.join(''), fd.dependent.join('')]
    end
  end

  def == other
    return false unless other.is_a?(FunctionalDependencySet)
    functional_dependencies == other.functional_dependencies
  end
end
