class Relation
  attr_reader :attributes, :functional_dependency_set

  def initialize attributes, fds = {}
    @attributes = attributes.sort.uniq
    @functional_dependency_set = FunctionalDependencySet.new(fds)
    @functional_dependency_set.functional_dependencies.each do |fd|
      if fd.determinant + fd.dependent - @attributes != []
        raise ArgumentError
      end
    end
  end

  def bcnf_decomposition
    return [self] unless violates_bcnf?

    attrs = functional_dependency_set.closure(@bcnf_violating_fd.determinant)
    fds = functional_dependency_set.related_to(attrs)
    r1 = Relation.new(attrs, fds).bcnf_decomposition

    attrs = (attributes - attrs + @bcnf_violating_fd.determinant).sort.uniq
    fds = functional_dependency_set.related_to(attrs)
    r2 = Relation.new(attrs, fds).bcnf_decomposition

    r1 + r2
  end

  def violates_bcnf?
    @bcnf_violating_fd = functional_dependency_set.bcnf_violating_fd(attributes)
    @bcnf_violating_fd != nil
  end

  def == other
    return false unless other.is_a?(Relation)
    attributes == other.attributes && functional_dependency_set == other.functional_dependency_set
  end
end
