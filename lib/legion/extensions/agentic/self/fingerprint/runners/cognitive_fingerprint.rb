# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Self
        module Fingerprint
          module Runners
            module CognitiveFingerprint
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def record_observation(category:, value:, partner_identity: nil, **)
                category = category.to_sym
                result   = engine_for(partner_identity).record_observation(category: category, value: value.to_f)
                log.debug "[cognitive_fingerprint] record category=#{category} " \
                          "baseline=#{result[:baseline]&.round(4)} samples=#{result[:samples]}"
                result
              end

              def verify_identity(observations:, partner_identity: nil, **)
                parsed = Array(observations).map do |obs|
                  { category: obs[:category].to_sym, value: obs[:value].to_f }
                end
                result = engine_for(partner_identity).verify_identity(observations: parsed)
                log.info "[cognitive_fingerprint] verify score=#{result[:match_score]&.round(4)} " \
                         "verdict=#{result[:verdict]}"
                result
              end

              def anomaly_check(category:, value:, partner_identity: nil, **)
                result = engine_for(partner_identity).anomaly_check(category: category.to_sym, value: value.to_f)
                if result[:anomaly]
                  log.warn "[cognitive_fingerprint] anomaly category=#{category} " \
                           "deviation=#{result[:deviation]&.round(4)}"
                end
                result
              end

              def trait_profile(partner_identity: nil, **)
                { profile: engine_for(partner_identity).trait_profile }
              end

              def strongest_traits(top_n: 3, partner_identity: nil, **)
                { traits: engine_for(partner_identity).strongest_traits(top_n.to_i) }
              end

              def weakest_traits(top_n: 3, partner_identity: nil, **)
                { traits: engine_for(partner_identity).weakest_traits(top_n.to_i) }
              end

              def identity_confidence(partner_identity: nil, **)
                engine = engine_for(partner_identity)
                confidence = engine.identity_confidence
                label      = engine.identity_label
                log.debug "[cognitive_fingerprint] confidence=#{confidence.round(4)} label=#{label}"
                { confidence: confidence, label: label }
              end

              def fingerprint_hash(partner_identity: nil, **)
                { fingerprint_hash: engine_for(partner_identity).fingerprint_hash }
              end

              def fingerprint_report(partner_identity: nil, **)
                engine_for(partner_identity).fingerprint_report
              end

              def fingerprint_status(partner_identity: nil, **)
                engine = engine_for(partner_identity)
                {
                  trait_count:  engine.trait_count,
                  sample_count: engine.sample_count,
                  label:        engine.identity_label
                }
              end

              def erase_partner!(identity:, **)
                registry = fingerprint_registry
                return { erased: false, identity: identity } unless registry.key?(identity)

                registry.delete(identity)
                log.info "[cognitive_fingerprint] erased partner identity=#{identity}"
                { erased: true, identity: identity }
              end

              def tracked_partners
                fingerprint_registry.keys.compact
              end

              private

              def engine_for(partner_identity)
                fingerprint_registry[partner_identity] ||= Helpers::FingerprintEngine.new
              end

              def fingerprint_registry
                @fingerprint_registry ||= {}
              end
            end
          end
        end
      end
    end
  end
end
