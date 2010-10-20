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

  describe '#closure' do
    it 'is the set of attributes functionally determined by the given attributes' do end

    before :each do
      @set = FunctionalDependencySet.new({
        'A' => 'B',
        'BC' => 'D',
        'DE' => 'FG'
      })
    end

    it 'always includes the attributes themselves' do
      @set.closure('FG').should == 'FG'
    end

    it 'includes directly determined attributes' do
      @set.closure('A').should == 'AB'
    end

    it 'includes deductively determined attributes' do
      @set.closure('AC').should == 'ABCD'
      @set.closure('ACE').should == 'ABCDEFG'
    end
  end
end
