# frozen_string_literal: true

require 'neo'
require 'neo/vm'

module Neo
  # Software Development Kit
  module SDK
    autoload :Builder,    'neo/sdk/builder'
    autoload :Contract,   'neo/sdk/contract'
    autoload :Script,     'neo/sdk/script'
    autoload :Simulation, 'neo/sdk/simulation'
    autoload :VERSION,    'neo/sdk/version'
  end
end
