# frozen_string_literal: true

require 'legion/extensions/agentic/self/reflection/helpers/constants'
require 'legion/extensions/agentic/self/reflection/helpers/reflection'
require 'legion/extensions/agentic/self/reflection/helpers/reflection_store'
require 'legion/extensions/agentic/self/reflection/helpers/monitors'
require 'legion/extensions/agentic/self/reflection/runners/reflection'

module Legion
  module Extensions
    module Agentic
      module Self
        module Reflection
          class Client
            include Runners::Reflection

            attr_reader :reflection_store

            def initialize(store: nil, **)
              @reflection_store = store || Helpers::ReflectionStore.new
            end
          end
        end
      end
    end
  end
end
