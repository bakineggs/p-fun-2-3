require 'rspec'
require 'functional_dependency_set'

describe FunctionalDependencySet do
  describe '#new' do
    it 'takes a hash of functional dependencies' do
      FunctionalDependencySet.new({
        ['A', 'B'] => ['C', 'D'],
        ['C'] => ['E']
      }).functional_dependencies.should == [
        FunctionalDependency.new(['A', 'B'], ['C', 'D']),
        FunctionalDependency.new(['C'], ['E'])
      ]
    end

    it 'does not understand duplicated determinants' do
      FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['B'] => ['C'],
        ['A'] => ['C']
      }).functional_dependencies.length.should == 2
    end
  end

  describe '#closure' do
    it 'is the complete set of functional dependencies implied by this set' do end

    it 'includes the given functional dependencies' do
      set = FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['C'] => ['D']
      })
      set.closure.should == set
    end

    it 'combines dependents' do
      FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['A'] => ['C']
      }).closure.should == FunctionalDependencySet.new({
        ['A'] => ['B', 'C'],
      })
    end

    it 'includes transitively determined dependencies' do
      FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['B'] => ['C']
      }).closure.should == FunctionalDependencySet.new({
        ['A'] => ['B', 'C'],
        ['B'] => ['C']
      })
    end

    it 'includes reflexively determined dependencies' do
      FunctionalDependencySet.new({
        ['A'] => ['B', 'C'],
        ['B'] => ['D']
      }).closure.should == FunctionalDependencySet.new({
        ['A'] => ['B', 'C', 'D'],
        ['B'] => ['D']
      })
    end

    it 'includes augmentally determined dependencies' do
      FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['B', 'C'] => ['D']
      }).closure.should == FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['B', 'C'] => ['D'],
        ['A', 'C'] => ['B', 'D']
      })
    end

    it 'eliminates redundant dependencies' do
      FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['A', 'B'] => ['C']
      }).closure.should == FunctionalDependencySet.new({
        ['A'] => ['B', 'C']
      })
    end
  end

  describe '#to_s' do
    it 'lists the functional dependencies' do
      set = FunctionalDependencySet.new({['A'] => ['B'], ['B', 'C'] => ['D']})
      [
        'A -> B, BC -> D',
        'BC -> D, A -> B'
      ].include?(set.to_s).should be_true
    end
  end

  describe '#==' do
    it 'determines equality based on functional dependencies' do
      set = FunctionalDependencySet.new({['A'] => ['B'], ['B', 'C'] => ['D']})
      set.should == FunctionalDependencySet.new({['A'] => ['B'], ['B', 'C'] => ['D']})
      set.should_not == FunctionalDependencySet.new({['A', 'C'] => ['B'], ['B', 'C'] => ['D']})
      set.should_not == FunctionalDependencySet.new({['A'] => ['B', 'C'], ['B', 'C'] => ['D']})
    end
  end
end
