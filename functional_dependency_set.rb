require 'functional_dependency'

class FunctionalDependencySet
  attr_reader :functional_dependencies

  def initialize fds
    @functional_dependencies = fds.to_a.map do |determinant, dependent|
      FunctionalDependency.new determinant, dependent
    end
  end
end
