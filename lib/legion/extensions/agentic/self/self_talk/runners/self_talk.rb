# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Self
        module SelfTalk
          module Runners
            module SelfTalk
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def register_voice(name:, voice_type:, volume: Helpers::Constants::DEFAULT_VOLUME,
                                 bias_direction: nil, **)
                result = engine.register_voice(
                  name:           name,
                  voice_type:     voice_type,
                  volume:         volume,
                  bias_direction: bias_direction
                )
                log.info "[self_talk] register_voice: name=#{name} type=#{voice_type} registered=#{result[:registered]}"
                result
              end

              def start_dialogue(topic:, **)
                result = engine.start_dialogue(topic: topic)
                log.debug "[self_talk] start_dialogue: topic=#{topic} id=#{result[:dialogue][:id]}"
                result
              end

              def add_turn(dialogue_id:, voice_id:, content:, position: :clarify, strength: 0.5, **)
                result = engine.add_turn(
                  dialogue_id: dialogue_id,
                  voice_id:    voice_id,
                  content:     content,
                  position:    position,
                  strength:    strength
                )
                log.debug "[self_talk] add_turn: dialogue=#{dialogue_id} voice=#{voice_id} added=#{result[:added]}"
                result
              end

              def conclude_dialogue(dialogue_id:, summary: nil, **)
                resolved_summary = summary || generate_summary_for_dialogue(dialogue_id)
                result = engine.conclude_dialogue(dialogue_id: dialogue_id, summary: resolved_summary)
                log.info "[self_talk] conclude_dialogue: id=#{dialogue_id} concluded=#{result[:concluded]}"
                result
              end

              def generate_voice_turn(dialogue_id:, voice_id:, **)
                dialogue_data = engine.dialogues[dialogue_id]
                voice_data    = engine.voices[voice_id]
                return missing_entity_error(dialogue_data) unless dialogue_data && voice_data

                content, source = resolve_turn_content(voice_data, dialogue_data)
                turn_result = add_turn(
                  dialogue_id: dialogue_id,
                  voice_id:    voice_id,
                  content:     content[:content],
                  position:    content[:position]
                )
                log.debug "[self_talk] generate_voice_turn: dialogue=#{dialogue_id} voice=#{voice_id} source=#{source}"
                { generated: true, source: source, turn: turn_result[:turn] }
              end

              def deadlock_dialogue(dialogue_id:, **)
                result = engine.deadlock_dialogue(dialogue_id: dialogue_id)
                log.warn "[self_talk] deadlock_dialogue: id=#{dialogue_id} deadlocked=#{result[:deadlocked]}"
                result
              end

              def amplify_voice(voice_id:, amount: Helpers::Constants::VOLUME_BOOST, **)
                result = engine.amplify_voice(voice_id: voice_id, amount: amount)
                log.debug "[self_talk] amplify_voice: id=#{voice_id} volume=#{result[:volume]}"
                result
              end

              def dampen_voice(voice_id:, amount: Helpers::Constants::VOLUME_DECAY, **)
                result = engine.dampen_voice(voice_id: voice_id, amount: amount)
                log.debug "[self_talk] dampen_voice: id=#{voice_id} volume=#{result[:volume]}"
                result
              end

              def dialogue_report(dialogue_id:, **)
                result = engine.dialogue_report(dialogue_id: dialogue_id)
                log.debug "[self_talk] dialogue_report: id=#{dialogue_id} found=#{result[:found]}"
                result
              end

              def self_talk_status(**)
                summary = engine.to_h
                log.debug "[self_talk] status: voices=#{summary[:voice_count]} dialogues=#{summary[:dialogue_count]}"
                summary
              end

              def decay_voices(**)
                decayed = 0
                voice_list = engine.voices.values.select(&:active).map do |voice|
                  voice.dampen!(Helpers::Constants::VOLUME_DECAY)
                  decayed += 1
                  { id: voice.id, name: voice.name, volume: voice.volume }
                end
                log.debug "[self-talk] voice decay: decayed=#{decayed} voices"
                { decayed: decayed, voices: voice_list }
              end

              VOICE_BANK = {
                critic:     [
                  { content: 'What could go wrong with this approach?', position: :challenge },
                  { content: 'Are we overlooking any risks here?', position: :challenge },
                  { content: 'This needs more careful consideration.', position: :caution }
                ],
                advocate:   [
                  { content: 'This aligns with our core values.', position: :support },
                  { content: 'The potential benefits outweigh the risks.', position: :support },
                  { content: 'We should move forward with this.', position: :affirm }
                ],
                explorer:   [
                  { content: 'What alternatives have we not considered?', position: :explore },
                  { content: 'There may be an unconventional approach here.', position: :explore },
                  { content: 'Let us examine this from another angle.', position: :clarify }
                ],
                pragmatist: [
                  { content: 'What is the simplest path forward?', position: :simplify },
                  { content: 'Focus on what is actionable now.', position: :prioritize },
                  { content: 'We need concrete next steps.', position: :clarify }
                ]
              }.freeze

              VOICE_BANK_GENERIC = [
                { content: 'Let us think this through carefully.', position: :clarify },
                { content: 'More reflection is needed on this topic.', position: :clarify },
                { content: 'What do we know for certain here?', position: :clarify }
              ].freeze

              private

              def engine
                @engine ||= Helpers::SelfTalkEngine.new
              end

              def missing_entity_error(dialogue_data)
                { generated: false, reason: dialogue_data ? :voice_not_found : :dialogue_not_found }
              end

              def resolve_turn_content(voice_data, dialogue_data)
                prior_turns = build_prior_turns(dialogue_data)
                if Helpers::LlmEnhancer.available?
                  llm_result = Helpers::LlmEnhancer.generate_turn(
                    voice_type:  voice_data.voice_type,
                    topic:       dialogue_data.topic,
                    prior_turns: prior_turns
                  )
                  return [llm_result, :llm] if llm_result
                end
                [mechanical_turn_content(voice_data.voice_type, dialogue_data.topic), :mechanical]
              end

              def build_prior_turns(dialogue_data)
                dialogue_data.turns.map do |t|
                  speaking_voice = engine.voices[t.voice_id]
                  { voice_id: t.voice_id, voice_name: speaking_voice&.name || t.voice_id,
                    position: t.position, content: t.content }
                end
              end

              def mechanical_turn_content(voice_type, _topic)
                bank = VOICE_BANK.fetch(voice_type.to_sym, VOICE_BANK_GENERIC)
                bank.sample
              end

              def generate_summary_for_dialogue(dialogue_id)
                dialogue_data = engine.dialogues[dialogue_id]
                return mechanical_summary(nil) unless dialogue_data

                if Helpers::LlmEnhancer.available?
                  turns = dialogue_data.turns.map do |t|
                    speaking_voice = engine.voices[t.voice_id]
                    {
                      voice_id:   t.voice_id,
                      voice_name: speaking_voice&.name || t.voice_id,
                      position:   t.position,
                      content:    t.content
                    }
                  end

                  llm_result = Helpers::LlmEnhancer.summarize_dialogue(
                    topic: dialogue_data.topic,
                    turns: turns
                  )
                  return llm_result[:summary] if llm_result
                end

                mechanical_summary(dialogue_data)
              end

              def mechanical_summary(dialogue_data)
                turns = dialogue_data&.turns || []
                voices = turns.filter_map { |t| t.respond_to?(:voice_id) ? engine.voices[t.voice_id]&.name || t.voice_id : t[:voice_id] }.uniq
                positions = turns.filter_map { |t| t.respond_to?(:position) ? t.position : t[:position] }.tally
                dominant = positions.max_by { |_, count| count }&.first
                "#{turns.size} turns across #{voices.join(', ')} voices. Dominant position: #{dominant || 'none'}."
              end
            end
          end
        end
      end
    end
  end
end
