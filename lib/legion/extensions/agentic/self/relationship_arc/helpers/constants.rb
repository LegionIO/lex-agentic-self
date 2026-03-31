# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Self
        module RelationshipArc
          module Helpers
            module Constants
              CHAPTERS = %i[formative developing established deepening].freeze

              MILESTONE_TYPES = %i[
                first_interaction first_direct_address stage_transition
                prediction_accuracy communication_shift absence_return
              ].freeze

              HEALTH_WEIGHTS = {
                attachment_strength: 0.4,
                reciprocity_balance: 0.3,
                communication_consistency: 0.3
              }.freeze

              MAX_MILESTONES = 200

              CHAPTER_THRESHOLDS = {
                developing:  { milestones: 3,  stage: :forming },
                established: { milestones: 10, stage: :established },
                deepening:   { milestones: 25, stage: :deep }
              }.freeze

              TAG_PREFIX = %w[bond relationship_arc].freeze
              MILESTONE_TAG_PREFIX = %w[bond milestone].freeze
            end
          end
        end
      end
    end
  end
end
