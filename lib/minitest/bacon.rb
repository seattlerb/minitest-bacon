#!/usr/bin/ruby -w

ENV["MT_NO_EXPECTATIONS"] = "1"
require "minitest/autorun"

module Minitest
  def self.poke
    Minitest::Spec.current.assertions += 1
  end

  def self.count
    Minitest::Spec.current.assertions
  end
end

class Minitest::Assertion
  alias :oldloc :location

  # override to add method_missing

  def location # :nodoc:
    last_before_assertion = ""
    self.backtrace.reverse_each do |s|
      break if s =~ /in .(method_missing|assert|refute|flunk|pass|fail|raise|must|wont)/
      last_before_assertion = s
    end
    last_before_assertion.sub(/:in .*$/, "")
  end
end

class Minitest::ValueMonad
  VERSION = "1.0.4"

  instance_methods.each { |name| undef_method name  if name =~ /\?|^\W+$/ }

  def initialize v
    @val = v
    @pos = true
  end

  def not(*args, &block)
    @pos = !@pos

    be(*args, &block)
  end

  def be(*args, &block)
    if args.empty?
      self
    else
      block = args.shift unless block_given?
      block ||= lambda { @val.send(*args) }
      assert(&block)
    end
  end

  alias a  be
  alias an be

  def be_true
    assert { @val }
  end

  def be_false
    assert { !@val }
  end

  def assert msg = nil
    r = yield @val

    Minitest.poke
    msg ||= "boom"
    raise Minitest::Assertion, msg if @pos ^ r

    r
  end

  def method_missing(name, *args, &block)
    name = name.to_s.sub(/^be_/, '')
    name = "#{name}?" if name =~ /\w[^?]\z/

    msg = []
    msg << "not" unless @pos
    msg << @val.inspect << ".#{name}"
    msg << "(#{args.map(&:inspect).join ", "}) failed"

    assert(msg.join) { @val.__send__(name, *args, &block) }
  end

  def equal(value)         self == value      end
  def match(value)         self =~ value      end
  def identical_to(value)  self.equal? value  end
  alias same_as identical_to

  def raise?(*args,  &block); block.raise?(*args);  end
  def throw?(*args,  &block); block.throw?(*args);  end
  def change?(*args, &block); block.change?(*args); end

  def flunk(reason="Flunked")
    raise Minitest::Assertion, reason
  end
end

class Minitest::SelfMonad < Minitest::ValueMonad
  def initialize
    super self
    @depth = 0
  end

  def method_missing(name, *args, &block) # hacky, saves my butt on StackDepth
    @depth += 1
    super unless @depth > 1
  ensure
    @depth -= 1
  end
end

class Minitest::Spec
  class << self
    alias should it
  end

  def should
    Minitest::SelfMonad.new
  end

  def self.behaves_like(*names)
    names.each do |name|
      mod = Minitest::Shared[name]
      raise NameError, "Unknown shared module #{name}" unless mod
      include mod
    end
  end
end

Minitest::Shared = {}

class Object
  alias eq? ==

  def true?
    !!self
  end

  def should(*args, &block)
    Minitest::ValueMonad.new(self).be(*args, &block)
  end

  def shared(name, &block)
    Minitest::Shared[name] = Module.new do |m|
      (class << m; self; end).send :define_method, :included do |cls|
        cls.instance_eval(&block)
      end
    end
  end
end

class Proc
  def raise?(*exceptions)
    exceptions = [RuntimeError] if exceptions.empty?
    call
  rescue *exceptions => e
    e
  else
    false
  end

  def throw?(sym)
    not catch(sym) {
      call
      return false
    }
    return true
  end

  def change?
    before = yield
    call
    after = yield
    before != after
  end
end

class Numeric
  alias lt?           <
  alias gt?           >
  alias gte?          >=
  alias less_than?    <
  alias greater_than? >

  def close?(to, delta = 0.001)
    (self - to).abs <= delta rescue false
  end
end
