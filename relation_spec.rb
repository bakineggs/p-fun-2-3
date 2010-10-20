require 'spec'
require 'relation'

describe Relation do
  describe '#new' do
    it 'takes a list of capital letters as attribute names' do
      r = Relation.new 'ABCD'
      r.attributes.should == ['A', 'B', 'C', 'D']
    end

    it 'assumes there are no functional dependencies if not specified' do
      r = Relation.new 'ABCD'
      r.functional_dependency_set.functional_dependencies.should be_empty
    end

    it 'takes a set of functional dependencies' do
      r = Relation.new 'ABCD', {'A' => 'B', 'C' => 'D'}
      r.functional_dependency_set.functional_dependencies.should == [
        FunctionalDependency.new('A', 'B'),
        FunctionalDependency.new('C', 'D')
      ]
    end
  end
end
