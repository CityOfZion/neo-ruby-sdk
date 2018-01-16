module Neo
  module VM
    # An execution context
    class Context
      attr_reader :script

      def initialize(script)
        @script = script
      end
    end
  end
end
