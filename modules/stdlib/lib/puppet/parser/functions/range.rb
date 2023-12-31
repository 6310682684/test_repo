# frozen_string_literal: true

#
# range.rb
#
# TODO(Krzysztof Wilczynski): We probably need to approach numeric values differently ...
module Puppet::Parser::Functions
  newfunction(:range, type: :rvalue, doc: <<-DOC
    @summary
      When given range in the form of (start, stop) it will extrapolate a range as
      an array.

    @return
      the range is extrapolated as an array

    @example **Usage**
      range("0", "9")
      Will return: [0,1,2,3,4,5,6,7,8,9]

      range("00", "09")
      Will return: [0,1,2,3,4,5,6,7,8,9]
      (Zero padded strings are converted to integers automatically)

      range("a", "c")
      Will return: ["a","b","c"]

      range("host01", "host10")
      Will return: ["host01", "host02", ..., "host09", "host10"]

      range("0", "9", "2")
      Will return: [0,2,4,6,8]

    NB Be explicit in including trailing zeros. Otherwise the underlying ruby function will fail.

    > *Note:*
      Passing a third argument will cause the generated range to step by that
      interval, e.g.

    The Puppet Language support Integer and Float ranges by using the type system. Those are suitable for
    iterating a given number of times.

    @see
      the step() function in Puppet for skipping values.

     Integer[0, 9].each |$x| { notice($x) } # notices 0, 1, 2, ... 9
  DOC
  ) do |arguments|
    raise(Puppet::ParseError, 'range(): Wrong number of arguments given (0 for 1)') if arguments.empty?

    if arguments.size > 1
      start = arguments[0]
      stop  = arguments[1]
      step  = arguments[2].nil? ? 1 : arguments[2].to_i.abs

      raise(ArgumentError, 'range(): 3rd arg (step size) must be a non zero integer (e.g. 1 or -1)') if step.zero?

      type = '..' # Use the simplest type of Range available in Ruby

    else # arguments.size == 1
      value = arguments[0]

      m = value.match(%r{^(\w+)(\.\.\.?|-)(\w+)$})
      if m
        start = m[1]
        stop  = m[3]

        type = m[2]
        step = 1
      elsif %r{^.+$}.match?(value)
        raise(Puppet::ParseError, "range(): Unable to compute range from the value: #{value}")
      else
        raise(Puppet::ParseError, "range(): Unknown range format: #{value}")
      end
    end

    # If we were given an integer, ensure we work with one
    if %r{^\d+$}.match?(start.to_s)
      start = start.to_i
      stop  = stop.to_i
    else
      start = start.to_s
      stop  = stop.to_s
    end

    range = case type
            when %r{^(..|-)$} then (start..stop)
            when '...' then (start...stop) # Exclusive of last element
            end

    result = range.step(step).first(1_000_000).to_a

    return result
  end
end

# vim: set ts=2 sw=2 et :
