# frozen_string_literal: true

require 'neo'
require 'neo/vm'

module Neo
  # Software Development Kit
  module SDK
    autoload :Builder,  'neo/sdk/builder'
    autoload :Contract, 'neo/sdk/contract'
    autoload :Script,   'neo/sdk/script'
    autoload :VERSION,  'neo/sdk/version'
  end
end
