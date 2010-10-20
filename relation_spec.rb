require 'spec'
require 'relation'

describe Relation do
  describe '#new' do
    it 'takes a list of attributes' do
      r = Relation.new ['A', 'B', 'C', 'D']
      r.attributes.should == ['A', 'B', 'C', 'D']
    end

    it 'assumes there are no functional dependencies if not specified' do
      r = Relation.new ['A', 'B', 'C', 'D']
      r.functional_dependency_set.functional_dependencies.should be_empty
    end

    it 'takes a set of functional dependencies' do
      fds = {['A'] => ['B'], ['C'] => ['D']}
      r = Relation.new ['A', 'B', 'C', 'D'], fds
      r.functional_dependency_set.should == FunctionalDependencySet.new(fds)
    end

    it 'does not allow functional dependencies related to non-attributes' do
      lambda {
        r = Relation.new ['A', 'B', 'C', 'D'], {['A'] => ['B'], ['C'] => ['E']}
      }.should raise_error(ArgumentError)

      lambda {
        r = Relation.new ['A', 'B', 'C', 'D'], {['A'] => ['B'], ['E'] => ['D']}
      }.should raise_error(ArgumentError)
    end
  end

  describe '#bcnf_decomposition' do
    it 'is a set of derived relations with the determinants of any relevant functional dependencies being keys' do end

    it 'splits up a relation with a functional dependency and an independent attribute' do
      r = Relation.new ['A', 'B', 'C'], {['A'] => ['B']}
      r.bcnf_decomposition.should == [
        Relation.new(['A', 'B'], {['A'] => ['B']}),
        Relation.new(['A', 'C'])
      ]
    end

    it 'decomposes derived relations as well' do
      r = Relation.new ['A', 'B', 'C', 'D'], {['A'] => ['B'], ['C'] => ['D']}
      r.bcnf_decomposition.sort_by(&:attributes).should == [
        Relation.new(['A', 'B'], {['A'] => ['B']}),
        Relation.new(['A', 'C']),
        Relation.new(['C', 'D'], {['C'] => ['D']})
      ]
    end

    it 'does not preserve dependencies by default' do
      r = Relation.new ['A', 'B', 'C'], {['A'] => ['C'], ['B'] => ['C']}
      [
        [
          Relation.new(['A', 'B']),
          Relation.new(['A', 'C'], {['A'] => ['C']})
        ], [
          Relation.new(['A', 'B']),
          Relation.new(['B', 'C'], {['B'] => ['C']})
        ]
      ].include?(r.bcnf_decomposition.sort_by(&:attributes)).should be_true
    end
  end

  describe '#==' do
    it 'determines equality based on attributes and functional dependencies' do
      r = Relation.new ['A', 'B', 'C'], {['A'] => ['B']}
      r.should == Relation.new(['A', 'B', 'C'], {['A'] => ['B']})
      r.should_not == Relation.new(['A', 'B', 'C', 'D'], {['A'] => ['B']})
      r.should_not == Relation.new(['A', 'B', 'C'], {['A'] => ['C']})
    end
  end
end
