# frozen_string_literal: true

require 'legion/extensions/agentic/self/fingerprint/helpers/constants'
require 'legion/extensions/agentic/self/fingerprint/helpers/cognitive_trait'
require 'legion/extensions/agentic/self/fingerprint/helpers/fingerprint_engine'
require 'legion/extensions/agentic/self/fingerprint/runners/cognitive_fingerprint'

module Legion
  module Extensions
    module Agentic
      module Self
        module Fingerprint
          class Client
            include Runners::CognitiveFingerprint
          end
        end
      end
    end
  end
end
