# frozen_string_literal: true

#
# prefix.rb
#
module Puppet::Parser::Functions
  newfunction(:prefix, type: :rvalue, doc: <<-DOC
    @summary
      This function applies a prefix to all elements in an array or a hash.

    @example **Usage**

      prefix(['a','b','c'], 'p')
      Will return: ['pa','pb','pc']

    > *Note:* since Puppet 4.0.0 the general way to modify values is in array is by using the map
    function in Puppet. This example does the same as the example above:
    ['a', 'b', 'c'].map |$x| { "p${x}" }

    @return [Hash] or [Array] The passed values now contains the passed prefix
  DOC
  ) do |arguments|
    # Technically we support two arguments but only first is mandatory ...
    raise(Puppet::ParseError, "prefix(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    enumerable = arguments[0]

    raise Puppet::ParseError, "prefix(): expected first argument to be an Array or a Hash, got #{enumerable.inspect}" unless enumerable.is_a?(Array) || enumerable.is_a?(Hash)

    prefix = arguments[1] if arguments[1]

    raise Puppet::ParseError, "prefix(): expected second argument to be a String, got #{prefix.inspect}" if prefix && !prefix.is_a?(String)

    result = if enumerable.is_a?(Array)
               # Turn everything into string same as join would do ...
               enumerable.map do |i|
                 i = i.to_s
                 prefix ? prefix + i : i
               end
             else
               enumerable.to_h do |k, v|
                 k = k.to_s
                 [prefix ? prefix + k : k, v]
               end
             end

    return result
  end
end

# vim: set ts=2 sw=2 et :
