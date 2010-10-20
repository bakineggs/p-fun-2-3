class FunctionalDependency
  attr_reader :determinant, :dependent

  def initialize determinant, dependent
    @determinant = determinant.sort.uniq
    @dependent = dependent.sort.uniq - @determinant
  end

  def == other
    return false unless other.is_a?(FunctionalDependency)
    determinant == other.determinant && dependent == other.dependent
  end
end
