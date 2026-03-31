# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/agentic/self/relationship_arc/helpers/constants'

RSpec.describe Legion::Extensions::Agentic::Self::RelationshipArc::Helpers::Constants do
  describe 'CHAPTERS' do
    it 'defines 4 chapters in order' do
      expect(described_class::CHAPTERS).to eq(%i[formative developing established deepening])
    end
  end

  describe 'MILESTONE_TYPES' do
    it 'includes expected types' do
      expect(described_class::MILESTONE_TYPES).to include(:first_interaction, :stage_transition,
                                                          :prediction_accuracy, :absence_return)
    end
  end

  describe 'HEALTH_WEIGHTS' do
    it 'sums to 1.0' do
      expect(described_class::HEALTH_WEIGHTS.values.sum).to eq(1.0)
    end
  end

  describe 'MAX_MILESTONES' do
    it 'caps at 200' do
      expect(described_class::MAX_MILESTONES).to eq(200)
    end
  end
end
