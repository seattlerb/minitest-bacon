= minitest-bacon

home :: https://github.com/seattlerb/minitest-bacon
rdoc :: http://docs.seattlerb.org/minitest-bacon

== DESCRIPTION:

minitest-bacon extends minitest with bacon-like functionality. It
should allow you to bridge 90+% of your bacon specs over to minitest.

== FEATURES/PROBLEMS:

* Passes almost all of bacon's tests.
* Where they don't it is documented why they don't.

=== Differences with Bacon:

* Only one before/after block per describe (ie, they're just methods again).
* Object#should doesn't work outside of describe. Not sure what that's for.
* Tests are no longer order dependent. This is a Good Thing™.

== SYNOPSIS:

    require "minitest/bacon"

    describe "A new array" do
      before do
        @ary = Array.new
      end

      it "should be empty" do
        @ary.should.be.empty
        @ary.should.not.include 1
      end

      it "should have zero size" do
        @ary.size.should.equal 0
        @ary.size.should.be.close 0.1, 0.5
      end

      it "should raise on trying fetch any index" do
        lambda { @ary.fetch 0 }.
          should.raise(IndexError).
          message.should.match(/out of array/)

        # Alternatively:
        should.raise(IndexError) { @ary.fetch 0 }
      end

      it "should have an object identity" do
        @ary.should.not.be.same_as Array.new
      end

      # Custom assertions are trivial to do, they are lambdas returning a
      # boolean vale:
      palindrome = lambda { |obj| obj == obj.reverse }
      it "should be a palindrome" do
        @ary.should.be.a palindrome
      end

      it "should have super powers" do
        should.flunk "no super powers found"
      end
    end

== REQUIREMENTS:

* minitest, 5+

== INSTALL:

* sudo gem install minitest-bacon

== LICENSE:

(The MIT License)

Copyright (c) Ryan Davis, seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
