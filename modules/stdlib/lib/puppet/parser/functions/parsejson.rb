# frozen_string_literal: true

require 'puppet/util/json'
#
# parsejson.rb
#
module Puppet::Parser::Functions
  newfunction(:parsejson, type: :rvalue, doc: <<-DOC
    @summary
      This function accepts JSON as a string and converts it into the correct
      Puppet structure.

    @return
      convert JSON into Puppet structure

    > *Note:*
      The optional second argument can be used to pass a default value that will
      be returned if the parsing of the JSON string failed or if the JSON parse
      evaluated to nil.
  DOC
  ) do |arguments|
    raise ArgumentError, 'Wrong number of arguments. 1 or 2 arguments should be provided.' unless arguments.length >= 1

    begin
      Puppet::Util::Json.load(arguments[0]) || arguments[1]
    rescue StandardError => e
      raise e unless arguments[1]

      arguments[1]
    end
  end
end

# vim: set ts=2 sw=2 et :
