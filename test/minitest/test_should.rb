require "minitest/bacon"

describe "#should shortcut for #it" do

  should "be called" do
    @called = true
    @called.should.be == true
  end

  should "save some characters by typing should" do
    lambda { should.assert { 1 == 1 } }.should.not.raise
  end

  should "save characters even on failure" do
    lambda { should.assert { 1 == 2 } }.should.raise Minitest::Assertion
  end

  should "work nested" do
    should.assert {1==1}
  end

  ##
  # Skipped because that's not how we do counting. minitest 5 will clean this up

  # count = Bacon::Counter[:specifications]
  # should "add new specifications" do
  #   # XXX this should +=1 but it's +=2
  #   (count+1).should == Bacon::Counter[:specifications]
  # end

  # should "have been called" do
  #   @called.should.be == true
  # end

end
