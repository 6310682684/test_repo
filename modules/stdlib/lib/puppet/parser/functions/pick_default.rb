# frozen_string_literal: true

#
# pick_default.rb
#
module Puppet::Parser::Functions
  newfunction(:pick_default, type: :rvalue, doc: <<-DOC
    @summary
      This function will return the first value in a list of values that is not undefined or an empty string.

    @return
      This function is similar to a coalesce function in SQL in that it will return
      the first value in a list of values that is not undefined or an empty string
      If no value is found, it will return the last argument.

    Typically, this function is used to check for a value in the Puppet
    Dashboard/Enterprise Console, and failover to a default value like the
    following:

      $real_jenkins_version = pick_default($::jenkins_version, '1.449')

    > *Note:*
      The value of $real_jenkins_version will first look for a top-scope variable
      called 'jenkins_version' (note that parameters set in the Puppet Dashboard/
      Enterprise Console are brought into Puppet as top-scope variables), and,
      failing that, will use a default value of 1.449.

      Contrary to the pick() function, the pick_default does not fail if
      all arguments are empty. This allows pick_default to use an empty value as
      default.
  DOC
  ) do |args|
    raise 'Must receive at least one argument.' if args.empty?

    default = args.last
    args = args[0..-2].compact
    args.delete(:undef)
    args.delete(:undefined)
    args.delete('')
    args << default
    return args[0]
  end
end
