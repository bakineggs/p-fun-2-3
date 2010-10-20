class Relation
  attr_reader :attributes, :functional_dependency_set

  def initialize attributes, fds = {}
    raise ArgumentError if attributes !~ /^[A-Z]+$/
    @attributes = attributes.chars.sort.uniq
    @functional_dependency_set = FunctionalDependencySet.new(fds)
  end
end
