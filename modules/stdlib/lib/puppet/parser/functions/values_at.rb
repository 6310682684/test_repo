# frozen_string_literal: true

#
# values_at.rb
#
module Puppet::Parser::Functions
  newfunction(:values_at, type: :rvalue, doc: <<-DOC
    @summary
      Finds value inside an array based on location.

    The first argument is the array you want to analyze, and the second element can
    be a combination of:

    * A single numeric index
    * A range in the form of 'start-stop' (eg. 4-9)
    * An array combining the above

    @return
      an array of values identified by location

    @example **Usage**

      values_at(['a','b','c'], 2)
      Would return ['c']

      values_at(['a','b','c'], ["0-1"])
      Would return ['a','b']

      values_at(['a','b','c','d','e'], [0, "2-3"])
      Would return ['a','c','d']

    > *Note:*
    Since Puppet 4.0.0 it is possible to slice an array with index and count directly in the language.
    A negative value is taken to be "from the end" of the array:

    `['a', 'b', 'c', 'd'][1, 2]`   results in `['b', 'c']`
    `['a', 'b', 'c', 'd'][2, -1]`  results in `['c', 'd']`
    `['a', 'b', 'c', 'd'][1, -2]`  results in `['b', 'c']`

  DOC
  ) do |arguments|
    raise(Puppet::ParseError, "values_at(): Wrong number of arguments given (#{arguments.size} for 2)") if arguments.size < 2

    array = arguments.shift

    raise(Puppet::ParseError, 'values_at(): Requires array to work with') unless array.is_a?(Array)

    indices = [arguments.shift].flatten # Get them all ... Pokemon ...

    raise(Puppet::ParseError, 'values_at(): You must provide at least one positive index to collect') if !indices || indices.empty?

    indices_list = []

    indices.each do |i|
      i = i.to_s
      m = i.match(%r{^(\d+)(\.\.\.?|-)(\d+)$})
      if m
        start = m[1].to_i
        stop  = m[3].to_i

        type = m[2]

        raise(Puppet::ParseError, 'values_at(): Stop index in given indices range is smaller than the start index') if start > stop
        raise(Puppet::ParseError, 'values_at(): Stop index in given indices range exceeds array size') if stop > array.size - 1 # First element is at index 0 is it not?

        range = case type
                when %r{^(\.\.|-)$} then (start..stop)
                when %r{^(\.\.\.)$} then (start...stop) # Exclusive of last element ...
                end

        range.each { |i| indices_list << i.to_i } # rubocop:disable Lint/ShadowingOuterLocalVariable : Value is meant to be shadowed
      else
        # Only positive numbers allowed in this case ...
        raise(Puppet::ParseError, 'values_at(): Unknown format of given index') unless %r{^\d+$}.match?(i)

        # In Puppet numbers are often string-encoded ...
        i = i.to_i

        raise(Puppet::ParseError, 'values_at(): Given index exceeds array size') if i > array.size - 1 # Same story.  First element is at index 0 ...

        indices_list << i
      end
    end

    # We remove nil values as they make no sense in Puppet DSL ...
    result = indices_list.map { |i| array[i] }.compact

    return result
  end
end

# vim: set ts=2 sw=2 et :
