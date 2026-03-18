# frozen_string_literal: true

require 'legion/extensions/agentic/self/metacognition/helpers/constants'
require 'legion/extensions/agentic/self/metacognition/helpers/self_model'
require 'legion/extensions/agentic/self/metacognition/helpers/snapshot_store'
require 'legion/extensions/agentic/self/metacognition/helpers/narrator_bridge'
require 'legion/extensions/agentic/self/metacognition/runners/metacognition'

module Legion
  module Extensions
    module Agentic
      module Self
        module Metacognition
          class Client
            include Runners::Metacognition

            attr_reader :snapshot_store

            def initialize(snapshot_store: nil, **)
              @snapshot_store = snapshot_store || Helpers::SnapshotStore.new
            end
          end
        end
      end
    end
  end
end
