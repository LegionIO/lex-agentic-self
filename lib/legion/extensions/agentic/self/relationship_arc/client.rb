# frozen_string_literal: true

require 'legion/extensions/agentic/self/relationship_arc/helpers/constants'
require 'legion/extensions/agentic/self/relationship_arc/helpers/milestone'
require 'legion/extensions/agentic/self/relationship_arc/helpers/arc_engine'
require 'legion/extensions/agentic/self/relationship_arc/runners/relationship_arc'

module Legion
  module Extensions
    module Agentic
      module Self
        module RelationshipArc
          class Client
            include Runners::RelationshipArc
          end
        end
      end
    end
  end
end
