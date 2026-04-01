# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/agentic/self/relationship_arc/helpers/constants'
require 'legion/extensions/agentic/self/relationship_arc/helpers/milestone'
require 'legion/extensions/agentic/self/relationship_arc/helpers/arc_engine'

RSpec.describe Legion::Extensions::Agentic::Self::RelationshipArc::Helpers::ArcEngine do
  subject(:engine) { described_class.new(agent_id: 'partner-1') }

  describe '#initialize' do
    it 'starts in formative chapter' do
      expect(engine.current_chapter).to eq(:formative)
    end

    it 'starts with empty milestones' do
      expect(engine.milestones).to be_empty
    end
  end

  describe '#add_milestone' do
    it 'adds a milestone' do
      engine.add_milestone(type: :first_interaction, description: 'Hello', significance: 0.8)
      expect(engine.milestones.size).to eq(1)
    end

    it 'returns the milestone' do
      ms = engine.add_milestone(type: :first_interaction, description: 'Hello', significance: 0.8)
      expect(ms).to be_a(Legion::Extensions::Agentic::Self::RelationshipArc::Helpers::Milestone)
    end

    it 'marks dirty' do
      engine.add_milestone(type: :first_interaction, description: 'Hello', significance: 0.8)
      expect(engine).to be_dirty
    end

    it 'caps at MAX_MILESTONES' do
      201.times { |i| engine.add_milestone(type: :first_interaction, description: "ms #{i}", significance: 0.1) }
      expect(engine.milestones.size).to eq(200)
    end
  end

  describe '#update_chapter!' do
    it 'transitions to developing after enough milestones' do
      4.times { engine.add_milestone(type: :first_interaction, description: 'x', significance: 0.5) }
      engine.update_chapter!(bond_stage: :forming)
      expect(engine.current_chapter).to eq(:developing)
    end

    it 'never regresses' do
      engine.instance_variable_set(:@current_chapter, :established)
      engine.update_chapter!(bond_stage: :initial)
      expect(engine.current_chapter).to eq(:established)
    end
  end

  describe '#relationship_health' do
    it 'computes weighted health score' do
      health = engine.relationship_health(
        attachment_strength:       0.8,
        reciprocity_balance:       0.6,
        communication_consistency: 0.7
      )
      expected = (0.8 * 0.4) + (0.6 * 0.3) + (0.7 * 0.3)
      expect(health).to be_within(0.01).of(expected)
    end

    it 'clamps to 0.0..1.0' do
      health = engine.relationship_health(
        attachment_strength:       1.5,
        reciprocity_balance:       1.5,
        communication_consistency: 1.5
      )
      expect(health).to eq(1.0)
    end
  end

  describe '#dirty? and #mark_clean!' do
    it 'starts clean' do
      expect(engine).not_to be_dirty
    end

    it 'cleans up' do
      engine.add_milestone(type: :first_interaction, description: 'x', significance: 0.5)
      engine.mark_clean!
      expect(engine).not_to be_dirty
    end
  end

  describe '#to_apollo_entries' do
    before { engine.add_milestone(type: :first_interaction, description: 'Hello', significance: 0.8) }

    it 'returns entries with arc state' do
      entries = engine.to_apollo_entries
      expect(entries).to be_an(Array)
      expect(entries.first[:tags]).to include('bond', 'relationship_arc', 'partner-1')
    end
  end

  describe '#from_apollo' do
    let(:mock_store) { double('apollo_local') }

    it 'restores state from Apollo' do
      engine.add_milestone(type: :first_interaction, description: 'Hello', significance: 0.8)
      engine.instance_variable_set(:@current_chapter, :developing)
      content = engine.send(:serialize, engine.send(:arc_state_hash))

      new_engine = described_class.new(agent_id: 'partner-1')
      allow(mock_store).to receive(:query)
        .and_return({ success: true, results: [{ content: content, tags: %w[bond relationship_arc partner-1] }] })

      expect(new_engine.from_apollo(store: mock_store)).to be true
      expect(new_engine.current_chapter).to eq(:developing)
      expect(new_engine.milestones.size).to eq(1)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      h = engine.to_h
      expect(h).to include(:agent_id, :current_chapter, :milestones, :relationship_health)
    end

    it 'relationship_health is nil before relationship_health() is called' do
      expect(engine.to_h[:relationship_health]).to be_nil
    end

    it 'relationship_health reflects the last computed value' do
      engine.relationship_health(
        attachment_strength:       0.8,
        reciprocity_balance:       0.6,
        communication_consistency: 0.7
      )
      h = engine.to_h
      expected = (0.8 * 0.4) + (0.6 * 0.3) + (0.7 * 0.3)
      expect(h[:relationship_health]).to be_within(0.01).of(expected)
    end

    it 'includes milestone_count' do
      engine.add_milestone(type: :first_interaction, description: 'x', significance: 0.5)
      expect(engine.to_h[:milestone_count]).to eq(1)
    end
  end

  describe '#arc_state_hash (via to_apollo_entries)' do
    it 'includes milestones_today for milestones added today' do
      engine.add_milestone(type: :first_interaction, description: 'today', significance: 0.9)
      entries = engine.to_apollo_entries
      parsed = JSON.parse(entries.first[:content], symbolize_names: true)
      expect(parsed).to have_key(:milestones_today)
      expect(parsed[:milestones_today].size).to eq(1)
    end

    it 'milestones_today is empty when milestones have old timestamps' do
      ms = Legion::Extensions::Agentic::Self::RelationshipArc::Helpers::Milestone.new(
        type: :first_interaction, description: 'old', significance: 0.5,
        created_at: Time.now.utc - (2 * 86_400)
      )
      engine.instance_variable_get(:@milestones) << ms
      entries = engine.to_apollo_entries
      parsed = JSON.parse(entries.first[:content], symbolize_names: true)
      expect(parsed[:milestones_today]).to eq([])
    end
  end
end
