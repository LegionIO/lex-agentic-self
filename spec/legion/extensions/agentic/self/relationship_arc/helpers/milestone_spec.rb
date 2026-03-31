# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/agentic/self/relationship_arc/helpers/constants'
require 'legion/extensions/agentic/self/relationship_arc/helpers/milestone'

RSpec.describe Legion::Extensions::Agentic::Self::RelationshipArc::Helpers::Milestone do
  subject(:milestone) do
    described_class.new(type: :first_interaction, description: 'First hello', significance: 0.8)
  end

  describe '#initialize' do
    it 'sets type' do
      expect(milestone.type).to eq(:first_interaction)
    end

    it 'generates a UUID' do
      expect(milestone.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'clamps significance to 0.0..1.0' do
      ms = described_class.new(type: :first_interaction, description: 'test', significance: 1.5)
      expect(ms.significance).to eq(1.0)
    end

    it 'records timestamp' do
      expect(milestone.created_at).to be_a(Time)
    end
  end

  describe '#to_h' do
    it 'returns complete hash' do
      h = milestone.to_h
      expect(h).to include(:id, :type, :description, :significance, :created_at)
    end
  end

  describe '.from_h' do
    it 'round-trips' do
      restored = described_class.from_h(milestone.to_h)
      expect(restored.type).to eq(milestone.type)
      expect(restored.description).to eq(milestone.description)
      expect(restored.significance).to eq(milestone.significance)
    end
  end
end
