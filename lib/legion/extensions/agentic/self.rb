# frozen_string_literal: true

require_relative 'self/version'
require_relative 'self/fingerprint'
require_relative 'self/narrative_arc'
require_relative 'self/anchor'
require_relative 'self/architecture'
require_relative 'self/narrative_identity'
require_relative 'self/narrative_self'
require_relative 'self/metacognition'
require_relative 'self/metacognitive_monitoring'
require_relative 'self/self_model'
require_relative 'self/self_talk'
require_relative 'self/identity'
require_relative 'self/personality'
require_relative 'self/agency'
require_relative 'self/reflection'
require_relative 'self/anosognosia'
require_relative 'self/default_mode_network'
require_relative 'self/relationship_arc'

module Legion
  module Extensions
    module Agentic
      module Self
        extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core, false

        def self.remote_invocable?
          false
        end
      end
    end
  end
end
