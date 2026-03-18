# frozen_string_literal: true

require 'legion/extensions/agentic/self/identity/version'
require 'legion/extensions/agentic/self/identity/helpers/dimensions'
require 'legion/extensions/agentic/self/identity/helpers/fingerprint'
require 'legion/extensions/agentic/self/identity/helpers/vault_secrets'
require 'legion/extensions/agentic/self/identity/runners/identity'
require 'legion/extensions/agentic/self/identity/runners/entra'
require 'legion/extensions/agentic/self/identity/actors/orphan_check'
require 'legion/extensions/agentic/self/identity/client'

module Legion
  module Extensions
    module Agentic
      module Self
        module Identity
        end
      end
    end

    if defined?(Legion::Data::Local)
      Legion::Data::Local.register_migrations(
        name: :identity,
        path: File.join(__dir__, 'identity', 'local_migrations')
      )
    end
  end
end
