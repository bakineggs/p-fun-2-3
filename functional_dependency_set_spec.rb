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

    before :each do
      @set = FunctionalDependencySet.new({
        ['A'] => ['B'],
        ['B', 'C'] => ['D'],
        ['D', 'E'] => ['F', 'G']
      })
    end

    it 'always includes the attributes themselves' do
      fail
      @set.closure(['F', 'G']).should == ['F', 'G']
    end

    it 'includes directly determined attributes' do
      fail
      @set.closure(['A']).should == ['A', 'B']
    end

    it 'includes deductively determined attributes' do
      fail
      @set.closure(['A', 'C']).should == ['A', 'B', 'C', 'D']
      @set.closure(['A', 'C', 'E']).should == ['A', 'B', 'C', 'D', 'E', 'F', 'G']
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
