# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Self
        module NarrativeIdentity
          module Actor
            class NarrativeDecay < Legion::Extensions::Actors::Every
              def runner_class
                Legion::Extensions::Agentic::Self::NarrativeIdentity::Runners::NarrativeIdentity
              end

              def runner_function
                'decay_themes'
              end

              def time
                600
              end

              def run_now?
                false
              end

              def use_runner?
                false
              end

              def check_subtask?
                false
              end

              def generate_task?
                false
              end
            end
          end
        end
      end
    end
  end
end
