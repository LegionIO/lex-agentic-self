# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Self
        module RelationshipArc
          module Helpers
            class Milestone
              attr_reader :id, :type, :description, :significance, :created_at

              def initialize(type:, description:, significance:, id: nil, created_at: nil)
                @id           = id || SecureRandom.uuid
                @type         = type.to_sym
                @description  = description
                @significance = significance.to_f.clamp(0.0, 1.0)
                @created_at   = created_at || Time.now.utc
              end

              def to_h
                { id: @id, type: @type, description: @description,
                  significance: @significance, created_at: @created_at.iso8601 }
              end

              def self.from_h(hash)
                new(
                  id:           hash[:id],
                  type:         hash[:type],
                  description:  hash[:description],
                  significance: hash[:significance],
                  created_at:   hash[:created_at] ? Time.parse(hash[:created_at].to_s) : nil
                )
              end
            end
          end
        end
      end
    end
  end
end
