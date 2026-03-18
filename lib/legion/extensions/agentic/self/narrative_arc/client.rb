# frozen_string_literal: true

require 'legion/extensions/agentic/self/narrative_arc/helpers/constants'
require 'legion/extensions/agentic/self/narrative_arc/helpers/beat_event'
require 'legion/extensions/agentic/self/narrative_arc/helpers/arc'
require 'legion/extensions/agentic/self/narrative_arc/helpers/arc_engine'
require 'legion/extensions/agentic/self/narrative_arc/runners/narrative'

module Legion
  module Extensions
    module Agentic
      module Self
        module NarrativeArc
          class Client
            include Runners::Narrative

            def initialize(**)
              @arc_engine = Helpers::ArcEngine.new
            end

            private

            attr_reader :arc_engine
          end
        end
      end
    end
  end
end
