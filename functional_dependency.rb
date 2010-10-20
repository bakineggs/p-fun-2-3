class FunctionalDependency
  attr_reader :determinant, :dependent

  def initialize determinant, dependent
    raise ArgumentError if determinant !~ /^[A-Z]+$/ || dependent !~ /^[A-Z]+$/
    @determinant = determinant.chars.sort.uniq
    @dependent = dependent.chars.sort.uniq - @determinant
  end

  def == other
    return false unless other.is_a?(FunctionalDependency)
    determinant == other.determinant && dependent == other.dependent
  end
end
