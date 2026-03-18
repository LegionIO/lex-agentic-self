# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Self
        module Architecture
          class Client
            include Runners::CognitiveArchitecture

            def initialize(**)
              @engine = Helpers::ArchitectureEngine.new
            end
          end
        end
      end
    end
  end
end
