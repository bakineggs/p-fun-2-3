require 'spec'
require 'functional_dependency'

describe FunctionalDependency do
  describe '#new' do
    it 'takes a list of the determinant set and the dependent set' do
      fd = FunctionalDependency.new 'AB', 'CD'
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end

    it 'does not care about the order within the sets' do
      fd = FunctionalDependency.new 'BA', 'DC'
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end

    it 'does not care about duplicates within the sets' do
      fd = FunctionalDependency.new 'ABA', 'CDC'
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end

    it 'ignores trivialities' do
      fd = FunctionalDependency.new 'AB', 'ABCD'
      fd.determinant.should == ['A', 'B']
      fd.dependent.should == ['C', 'D']
    end

    it 'does not accept arguments other than strings of capital letters' do
      lambda {
        FunctionalDependency.new 'Ab', 'CD'
      }.should raise_error(ArgumentError)

      lambda {
        FunctionalDependency.new ['A', 'B'], ['C', 'D']
      }.should raise_error(ArgumentError)

      lambda {
        FunctionalDependency.new
      }.should raise_error(ArgumentError)
    end
  end

  describe '#==' do
    it 'determines equality based on the attributes' do
      fd = FunctionalDependency.new 'A', 'B'
      fd.should == FunctionalDependency.new('A', 'B')
      fd.should_not == FunctionalDependency.new('A', 'C')
      fd.should_not == FunctionalDependency.new('C', 'B')
    end
  end
end
