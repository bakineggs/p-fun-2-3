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

    it 'does not allow functional dependencies related to non-attributes' do
      lambda {
        r = Relation.new 'ABCD', {'A' => 'B', 'C' => 'E'}
      }.should raise_error(ArgumentError)

      lambda {
        r = Relation.new 'ABCD', {'A' => 'B', 'E' => 'D'}
      }.should raise_error(ArgumentError)
    end
  end

  describe '#bcnf_decomposition' do
    it 'is a set of derived relations with the determinants of any relevant functional dependencies being keys' do end

    it 'should split up a relation with a functional dependency and an independent attribute' do
      r = Relation.new 'ABC', {'A' => 'B'}
      r.bcnf_decomposition.should == [
        Relation.new('AB', {'A' => 'B'}),
        Relation.new('AC')
      ]
    end
  end

  describe '#==' do
    it 'determines equality based on attributes and functional dependencies' do
      r = Relation.new 'ABC', {'A' => 'B'}
      r.should == Relation.new('ABC', {'A' => 'B'})
      r.should_not == Relation.new('ABCD', {'A' => 'B'})
      r.should_not == Relation.new('ABC', {'A' => 'C'})
    end
  end
end
