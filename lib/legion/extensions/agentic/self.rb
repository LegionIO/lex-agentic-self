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

        def self.mcp_tools?
          false
        end

        def self.mcp_tools_deferred?
          false
        end

        def self.transport_required?
          false
        end

        def self.log
          Legion::Logging
        end

        def self.personality_snapshot
          client = Personality::Client.new
          client.personality_profile
        rescue StandardError => e
          log.warn "[self] personality_snapshot failed: #{e.message}"
          {}
        end

        def self.reflection_snapshot
          client = Reflection::Client.new
          result = client.recent_reflections(limit: 100)
          result.is_a?(Hash) ? (result[:reflections] || []) : []
        rescue StandardError => e
          log.warn "[self] reflection_snapshot failed: #{e.message}"
          []
        end

        def self.restore_personality(data)
          return unless data.is_a?(Hash) && !data.empty?

          log.info "[self] restore_personality: #{data.keys.join(', ')}"
        rescue StandardError => e
          log.error "[self] restore_personality failed: #{e.message}"
        end

        def self.restore_reflections(data)
          return unless data.is_a?(Array) && !data.empty?

          log.info "[self] restore_reflections: #{data.size} entries"
        rescue StandardError => e
          log.error "[self] restore_reflections failed: #{e.message}"
        end
      end
    end
  end
end
