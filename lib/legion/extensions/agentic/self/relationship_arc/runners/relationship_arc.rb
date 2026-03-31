# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Self
        module RelationshipArc
          module Runners
            module RelationshipArc
              include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def record_milestone(agent_id:, type:, description:, significance:, **)
                unless Helpers::Constants::MILESTONE_TYPES.include?(type.to_sym)
                  return { success: false,
                           error: "unknown type: #{type}" }
                end

                engine = arc_engine_for(agent_id)
                ms = engine.add_milestone(type: type, description: description, significance: significance)

                stamp_narrative_episode(ms)

                { success: true, milestone: ms.to_h }
              rescue StandardError => e
                { success: false, error: e.message }
              end

              def update_arc(agent_id:, attachment_state: {}, **)
                engine = arc_engine_for(agent_id)
                engine.update_chapter!(bond_stage: attachment_state[:bond_stage] || :initial)

                { success: true, current_chapter: engine.current_chapter,
                  milestone_count: engine.milestones.size }
              rescue StandardError => e
                { success: false, error: e.message }
              end

              def arc_stats(agent_id:, **)
                engine = arc_engine_for(agent_id)
                engine.to_h
              end

              private

              def arc_engine_for(agent_id)
                @arc_engines ||= {}
                @arc_engines[agent_id.to_s] ||= Helpers::ArcEngine.new(agent_id: agent_id.to_s)
              end

              def stamp_narrative_episode(milestone)
                narrator = resolve_narrative_identity
                return unless narrator

                narrator.record_episode(
                  content: milestone.description,
                  episode_type: :relationship,
                  emotional_valence: 0.3,
                  significance: milestone.significance,
                  domain: :relationship,
                  tags: ['partner', 'milestone', milestone.type.to_s]
                )
              rescue StandardError => e
                warn "[relationship_arc] narrative stamp failed: #{e.message}"
              end

              def resolve_narrative_identity
                return nil unless defined?(Legion::Extensions::Agentic::Self::NarrativeIdentity::Client)

                @narrative_client ||= Legion::Extensions::Agentic::Self::NarrativeIdentity::Client.new
              rescue StandardError
                nil
              end
            end
          end
        end
      end
    end
  end
end
