require 'rspec'
require 'functional_dependency'

describe FunctionalDependency do
  describe '#new' do
    it 'takes a list of the determinant set and the dependent set' do
      fd = FunctionalDependency.new ['A', 'B'], ['C', 'D']
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end

    it 'does not care about the order within the sets' do
      fd = FunctionalDependency.new ['B', 'A'], ['D', 'C']
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end

    it 'does not care about duplicates within the sets' do
      fd = FunctionalDependency.new ['A', 'B', 'A'], ['C', 'D', 'C']
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end

    it 'ignores trivialities' do
      fd = FunctionalDependency.new ['A', 'B'], ['A', 'B', 'C', 'D']
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end
  end

  describe '#to_s' do
    it 'lists the determinants and dependents' do
      fd = FunctionalDependency.new ['A'], ['B']
      fd.to_s.should == 'A -> B'

      fd = FunctionalDependency.new ['A', 'B'], ['C']
      fd.to_s.should == 'AB -> C'

      fd = FunctionalDependency.new ['A'], ['B', 'C']
      fd.to_s.should == 'A -> BC'
    end
  end

  describe '#==' do
    it 'determines equality based on the attributes' do
      fd = FunctionalDependency.new ['A'], ['B']
      fd.should == FunctionalDependency.new(['A'], ['B'])
      fd.should_not == FunctionalDependency.new(['A'], ['C'])
      fd.should_not == FunctionalDependency.new(['C'], ['B'])
    end
  end
end
