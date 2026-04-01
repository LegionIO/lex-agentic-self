# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Self
        module RelationshipArc
          module Helpers
            class ArcEngine
              attr_reader :agent_id, :current_chapter, :milestones

              BOND_STAGE_ORDER = %i[initial forming established deep].freeze
              private_constant :BOND_STAGE_ORDER

              def initialize(agent_id:)
                @agent_id        = agent_id
                @current_chapter = :formative
                @milestones      = []
                @dirty           = false
              end

              def add_milestone(type:, description:, significance:, **)
                ms = Milestone.new(type: type, description: description, significance: significance)
                @milestones << ms
                @milestones.shift while @milestones.size > Constants::MAX_MILESTONES
                @dirty = true
                ms
              end

              def update_chapter!(bond_stage: :initial, **)
                new_chapter = derive_chapter(bond_stage)
                return if Constants::CHAPTERS.index(new_chapter) <= Constants::CHAPTERS.index(@current_chapter)

                @current_chapter = new_chapter
                @dirty = true
              end

              def relationship_health(attachment_strength: 0.0, reciprocity_balance: 0.5,
                                      communication_consistency: 0.5, **)
                w = Constants::HEALTH_WEIGHTS
                score = (attachment_strength.to_f * w[:attachment_strength]) +
                        (reciprocity_balance.to_f * w[:reciprocity_balance]) +
                        (communication_consistency.to_f * w[:communication_consistency])
                @last_health = score.clamp(0.0, 1.0)
              end

              def dirty?
                @dirty
              end

              def mark_clean!
                @dirty = false
                self
              end

              def to_apollo_entries
                tags = Constants::TAG_PREFIX.dup + [@agent_id]
                tags << 'partner' if partner?(@agent_id)
                [{ content: serialize(arc_state_hash), tags: tags }]
              end

              def from_apollo(store:)
                result = store.query(text: 'relationship_arc', tags: Constants::TAG_PREFIX + [@agent_id])
                return false unless result[:success] && result[:results]&.any?

                parsed = deserialize(result[:results].first[:content])
                return false unless parsed

                @current_chapter = parsed[:current_chapter]&.to_sym || :formative
                @milestones = (parsed[:milestones] || []).map { |mh| Milestone.from_h(mh.transform_keys(&:to_sym)) }
                true
              rescue StandardError => e
                warn "[arc_engine] from_apollo error: #{e.message}"
                false
              end

              def to_h
                { agent_id: @agent_id, current_chapter: @current_chapter,
                  milestones: @milestones.map(&:to_h),
                  relationship_health: @last_health, milestone_count: @milestones.size }
              end

              private

              def arc_state_hash
                { agent_id: @agent_id, current_chapter: @current_chapter,
                  milestones: @milestones.map(&:to_h),
                  milestones_today: @milestones.select { |m| milestone_today?(m) }.map(&:to_h) }
              end

              def milestone_today?(milestone)
                ts = milestone.respond_to?(:created_at) ? milestone.created_at : milestone[:created_at]
                return false unless ts

                today = ::Time.now
                t = ts.is_a?(::Time) ? ts.localtime : ::Time.parse(ts.to_s)
                t.year == today.year && t.mon == today.mon && t.mday == today.mday
              rescue StandardError => e
                warn "[arc_engine] milestone_today? error: #{e.message}"
                false
              end

              def derive_chapter(bond_stage)
                Constants::CHAPTER_THRESHOLDS.each_key.reverse_each do |chapter|
                  threshold = Constants::CHAPTER_THRESHOLDS[chapter]
                  stage_idx = BOND_STAGE_ORDER.index(threshold[:stage]) || 0
                  current_stage_idx = BOND_STAGE_ORDER.index(bond_stage) || 0

                  return chapter if @milestones.size >= threshold[:milestones] &&
                                    current_stage_idx >= stage_idx
                end
                :formative
              end

              def partner?(agent_id)
                defined?(Legion::Gaia::BondRegistry) && Legion::Gaia::BondRegistry.partner?(agent_id)
              end

              def serialize(hash)
                defined?(Legion::JSON) ? Legion::JSON.dump(hash) : ::JSON.dump(hash)
              end

              def deserialize(content)
                parsed = defined?(Legion::JSON) ? Legion::JSON.parse(content) : ::JSON.parse(content, symbolize_names: true)
                parsed.is_a?(Hash) ? parsed.transform_keys(&:to_sym) : nil
              rescue StandardError => _e
                nil
              end
            end
          end
        end
      end
    end
  end
end
