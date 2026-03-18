# frozen_string_literal: true

require 'legion/extensions/agentic/self/narrative_self/helpers/constants'
require 'legion/extensions/agentic/self/narrative_self/helpers/episode'
require 'legion/extensions/agentic/self/narrative_self/helpers/narrative_thread'
require 'legion/extensions/agentic/self/narrative_self/helpers/autobiography'
require 'legion/extensions/agentic/self/narrative_self/runners/narrative_self'

module Legion
  module Extensions
    module Agentic
      module Self
        module NarrativeSelf
          class Client
            include Runners::NarrativeSelf

            attr_reader :autobiography

            def initialize(autobiography: nil, **)
              @autobiography = autobiography || Helpers::Autobiography.new
            end
          end
        end
      end
    end
  end
end
