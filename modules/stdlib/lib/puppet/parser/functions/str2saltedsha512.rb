# frozen_string_literal: true

#
#  str2saltedsha512.rb
#  Please note: This function is an implementation of a Ruby class and as such may not be entirely UTF8 compatible. To ensure compatibility please use this function with Ruby 2.4.0 or greater - https://bugs.ruby-lang.org/issues/10085.
#
module Puppet::Parser::Functions
  newfunction(:str2saltedsha512, type: :rvalue, doc: <<-DOC
    @summary
      This converts a string to a salted-SHA512 password hash (which is used for
      OS X versions >= 10.7).

    @return
      converted string as a hex version of a salted-SHA512 password hash

    Given any simple string, you will get a hex version
    of a salted-SHA512 password hash that can be inserted into your Puppet
    manifests as a valid password attribute.
  DOC
  ) do |arguments|
    require 'digest/sha2'

    raise(Puppet::ParseError, "str2saltedsha512(): Wrong number of arguments passed (#{arguments.size} but we require 1)") if arguments.size != 1

    password = arguments[0]

    raise(Puppet::ParseError, "str2saltedsha512(): Requires a String argument, you passed: #{password.class}") unless password.is_a?(String)

    seedint    = rand((2**31) - 1)
    seedstring = Array(seedint).pack('L')
    saltedpass = Digest::SHA512.digest(seedstring + password)
    (seedstring + saltedpass).unpack1('H*')
  end
end

# vim: set ts=2 sw=2 et :
