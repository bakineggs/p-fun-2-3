require 'functional_dependency_set'

class Relation
  attr_reader :attributes, :functional_dependency_set

  def initialize attributes, fds = {}
    @attributes = attributes.sort.uniq
    @functional_dependency_set = FunctionalDependencySet.new(fds).closure
    @functional_dependency_set.functional_dependencies.each do |fd|
      if fd.determinant + fd.dependent - @attributes != []
        raise ArgumentError
      end
    end
  end

  def bcnf_decomposition preserve_dependencies = false
    return [self] unless violates_bcnf?

    attrs = @bcnf_violating_fd.determinant + @bcnf_violating_fd.dependent
    fds1 = functional_dependency_set.related_to(attrs)
    r1 = Relation.new(attrs, fds1).bcnf_decomposition

    attrs = attributes - @bcnf_violating_fd.dependent
    fds2 = functional_dependency_set.related_to(attrs)
    r2 = Relation.new(attrs, fds2).bcnf_decomposition

    preserved_dependencies = (fds1 + fds2).uniq.length ==
                               functional_dependency_set.functional_dependencies.length

    if preserve_dependencies && !preserved_dependencies
      raise DependencyPreservationError
    end

    r1 + r2
  end

  def violates_bcnf?
    @bcnf_violating_fd = functional_dependency_set.bcnf_violating_fd(attributes)
    @bcnf_violating_fd != nil
  end

  def to_s
    fds = functional_dependency_set.to_s
    attrs = "(#{attributes.join(', ')})"
    if fds == ''
      attrs
    else
      "#{attrs}, #{fds}"
    end
  end

  def == other
    return false unless other.is_a?(Relation)
    attributes == other.attributes && functional_dependency_set == other.functional_dependency_set
  end
end

class DependencyPreservationError < StandardError
end
