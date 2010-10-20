require 'spec'
require 'functional_dependency_set'

describe FunctionalDependencySet do
  describe '#new' do
    it 'takes a hash of functional dependencies' do
      FunctionalDependencySet.new({
        'AB' => 'CD',
        'C' => 'E'
      }).functional_dependencies.should == [
        FunctionalDependency.new('AB', 'CD'),
        FunctionalDependency.new('C', 'E')
      ]
    end

    it 'does not understand duplicated determinants' do
      FunctionalDependencySet.new({
        'A' => 'B',
        'B' => 'C',
        'A' => 'C'
      }).functional_dependencies.length.should == 2
    end

    it 'only allows capital letters in functional dependencies' do
      lambda {
        FunctionalDependencySet.new({'Ab' => 'CD'})
      }.should raise_error(ArgumentError)
    end
  end
end
