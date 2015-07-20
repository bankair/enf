# encoding: utf-8

module Enf
  # This module holds the Enf version information.
  module Version
    STRING = '0.1.1'

    module_function

    def version(_debug = false)
      STRING
    end
  end
end
