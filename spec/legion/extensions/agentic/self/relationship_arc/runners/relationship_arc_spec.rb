# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/agentic/self/relationship_arc/helpers/constants'
require 'legion/extensions/agentic/self/relationship_arc/helpers/milestone'
require 'legion/extensions/agentic/self/relationship_arc/helpers/arc_engine'
require 'legion/extensions/agentic/self/relationship_arc/runners/relationship_arc'

RSpec.describe Legion::Extensions::Agentic::Self::RelationshipArc::Runners::RelationshipArc do
  let(:described_module) { described_class }
  let(:host) { Object.new.extend(described_module) }

  before { host.instance_variable_set(:@arc_engines, nil) }

  describe '#record_milestone' do
    it 'records a milestone for an agent' do
      result = host.record_milestone(agent_id: 'p1', type: :first_interaction,
                                     description: 'Hello', significance: 0.8)
      expect(result[:success]).to be true
      expect(result[:milestone][:type]).to eq(:first_interaction)
    end

    it 'returns error for unknown type' do
      result = host.record_milestone(agent_id: 'p1', type: :bogus,
                                     description: 'x', significance: 0.5)
      expect(result[:success]).to be false
    end

    it 'calls NarrativeIdentity record_episode when available' do
      narrator = double('narrator')
      allow(host).to receive(:resolve_narrative_identity).and_return(narrator)
      allow(narrator).to receive(:record_episode).and_return({ success: true })

      host.record_milestone(agent_id: 'p1', type: :first_interaction,
                            description: 'Hello', significance: 0.8)
      expect(narrator).to have_received(:record_episode)
        .with(hash_including(episode_type: :relationship, significance: 0.8))
    end
  end

  describe '#update_arc' do
    it 'updates chapter based on attachment state' do
      3.times do
        host.record_milestone(agent_id: 'p1', type: :first_interaction,
                              description: 'x', significance: 0.5)
      end
      result = host.update_arc(agent_id: 'p1', attachment_state: { bond_stage: :forming })
      expect(result[:success]).to be true
    end

    it 'returns arc summary' do
      result = host.update_arc(agent_id: 'p1', attachment_state: {})
      expect(result).to have_key(:current_chapter)
      expect(result).to have_key(:milestone_count)
    end
  end

  describe '#arc_stats' do
    it 'returns stats' do
      result = host.arc_stats(agent_id: 'p1')
      expect(result).to have_key(:current_chapter)
    end
  end
end
