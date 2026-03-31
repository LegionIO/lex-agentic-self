# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Self::Personality::Helpers::TraitModel do
  subject(:model) { described_class.new }

  let(:constants) { Legion::Extensions::Agentic::Self::Personality::Helpers::Constants }

  describe 'PARTNER_SIGNAL_MAP constant' do
    it 'defines partner_engagement_frequency nudging extraversion positively' do
      entry = constants::PARTNER_SIGNAL_MAP[:partner_engagement_frequency]
      expect(entry).to eq([:extraversion, :positive, 0.2])
    end

    it 'defines partner_direct_address_ratio nudging agreeableness positively' do
      entry = constants::PARTNER_SIGNAL_MAP[:partner_direct_address_ratio]
      expect(entry).to eq([:agreeableness, :positive, 0.2])
    end

    it 'defines partner_content_diversity nudging openness positively' do
      entry = constants::PARTNER_SIGNAL_MAP[:partner_content_diversity]
      expect(entry).to eq([:openness, :positive, 0.2])
    end

    it 'defines partner_consistency nudging conscientiousness positively' do
      entry = constants::PARTNER_SIGNAL_MAP[:partner_consistency]
      expect(entry).to eq([:conscientiousness, :positive, 0.2])
    end

    it 'has all entries with weights of 0.2' do
      constants::PARTNER_SIGNAL_MAP.each_value do |_trait, _direction, weight|
        expect(weight).to eq(0.2)
      end
    end

    it 'references only valid OCEAN traits' do
      constants::PARTNER_SIGNAL_MAP.each_value do |trait, _direction, _weight|
        expect(constants::TRAITS).to include(trait)
      end
    end
  end

  describe '#apply_partner_signals' do
    it 'nudges extraversion upward when partner_engagement_frequency is high' do
      baseline = model.trait(:extraversion)
      model.apply_partner_signals(partner_engagement_frequency: 0.9)
      expect(model.trait(:extraversion)).to be > baseline
    end

    it 'nudges agreeableness upward when partner_direct_address_ratio is high' do
      baseline = model.trait(:agreeableness)
      model.apply_partner_signals(partner_direct_address_ratio: 0.8)
      expect(model.trait(:agreeableness)).to be > baseline
    end

    it 'nudges openness upward when partner_content_diversity is high' do
      baseline = model.trait(:openness)
      model.apply_partner_signals(partner_content_diversity: 0.8)
      expect(model.trait(:openness)).to be > baseline
    end

    it 'nudges conscientiousness upward when partner_consistency is high' do
      baseline = model.trait(:conscientiousness)
      model.apply_partner_signals(partner_consistency: 0.8)
      expect(model.trait(:conscientiousness)).to be > baseline
    end

    it 'ignores signals below the minimum threshold' do
      baseline = model.trait(:extraversion)
      model.apply_partner_signals(partner_engagement_frequency: 0.1)
      expect(model.trait(:extraversion)).to eq(baseline)
    end

    it 'ignores signals exactly at the threshold boundary' do
      baseline = model.trait(:extraversion)
      model.apply_partner_signals(partner_engagement_frequency: 0.3)
      expect(model.trait(:extraversion)).to eq(baseline)
    end

    it 'applies multiple signals in a single call' do
      extraversion_before = model.trait(:extraversion)
      agreeableness_before = model.trait(:agreeableness)

      model.apply_partner_signals(
        partner_engagement_frequency: 0.9,
        partner_direct_address_ratio: 0.8
      )

      expect(model.trait(:extraversion)).to be > extraversion_before
      expect(model.trait(:agreeableness)).to be > agreeableness_before
    end

    it 'ignores unrecognized signal keys' do
      expect { model.apply_partner_signals(unknown_signal: 0.9) }.not_to raise_error
    end

    it 'does not change observation_count' do
      model.apply_partner_signals(partner_engagement_frequency: 0.9)
      expect(model.observation_count).to eq(0)
    end

    it 'records a history snapshot after applying signals' do
      model.apply_partner_signals(partner_engagement_frequency: 0.9)
      expect(model.history.size).to eq(1)
    end
  end
end
