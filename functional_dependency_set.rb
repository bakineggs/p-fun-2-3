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
      @functional_dependencies.each do |fd|
        if fd.determinant & closure == fd.determinant
          closure = (closure + fd.dependent).sort.uniq
        end
      end
    end

    closure.join('')
  end
end
