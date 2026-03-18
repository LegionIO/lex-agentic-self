# frozen_string_literal: true

require 'legion/extensions/agentic/self/identity/helpers/dimensions'
require 'legion/extensions/agentic/self/identity/helpers/fingerprint'
require 'legion/extensions/agentic/self/identity/runners/identity'

module Legion
  module Extensions
    module Agentic
      module Self
        module Identity
          class Client
            include Runners::Identity

            def initialize(**)
              @identity_fingerprint = Helpers::Fingerprint.new
            end

            private

            attr_reader :identity_fingerprint
          end
        end
      end
    end
  end
end
