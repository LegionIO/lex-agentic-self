# frozen_string_literal: true

require 'legion/extensions/agentic/self/anosognosia/helpers/constants'
require 'legion/extensions/agentic/self/anosognosia/helpers/cognitive_deficit'
require 'legion/extensions/agentic/self/anosognosia/helpers/anosognosia_engine'
require 'legion/extensions/agentic/self/anosognosia/runners/anosognosia'

module Legion
  module Extensions
    module Agentic
      module Self
        module Anosognosia
          class Client
            include Runners::Anosognosia

            def initialize(**)
              @engine = Helpers::AnosognosiaEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end
