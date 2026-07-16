# frozen_string_literal: true

require 'legion/extensions/agentic/self/fingerprint/client'

RSpec.describe 'CognitiveFingerprint per-partner identity scoping' do
  let(:client) { Legion::Extensions::Agentic::Self::Fingerprint::Client.new }

  def seed(partner, category, value, count = 10)
    count.times { client.record_observation(category: category, value: value, partner_identity: partner) }
  end

  describe 'isolation between partners' do
    it 'observations for partner X are not visible to partner Y' do
      seed('alice', :accuracy, 0.9)
      result = client.fingerprint_status(partner_identity: 'bob')
      expect(result[:trait_count]).to eq(0)
    end

    it 'partner X traits are visible when queried for X' do
      seed('alice', :accuracy, 0.9)
      result = client.fingerprint_status(partner_identity: 'alice')
      expect(result[:trait_count]).to eq(1)
    end

    it 'two partners maintain independent baselines' do
      seed('alice', :accuracy, 0.9)
      seed('bob', :accuracy, 0.1)
      alice_profile = client.trait_profile(partner_identity: 'alice')[:profile]
      bob_profile   = client.trait_profile(partner_identity: 'bob')[:profile]
      expect(alice_profile[:accuracy]).to be > 0.5
      expect(bob_profile[:accuracy]).to be < 0.5
    end

    it 'verify_identity for X never sees Y data' do
      seed('alice', :accuracy, 0.9, 20)
      result = client.verify_identity(observations:     [{ category: :accuracy, value: 0.9 }],
                                      partner_identity: 'bob')
      expect(result[:verdict]).to eq(:insufficient_data)
    end

    it 'anomaly_check for X never uses Y baseline' do
      seed('alice', :accuracy, 0.9, 10)
      result = client.anomaly_check(category: :accuracy, value: 0.9, partner_identity: 'bob')
      expect(result[:reason]).to eq(:no_baseline)
    end
  end

  describe '#erase_partner!' do
    before { seed('alice', :accuracy, 0.9) }

    it 'removes all data for the named partner' do
      client.erase_partner!(identity: 'alice')
      result = client.fingerprint_status(partner_identity: 'alice')
      expect(result[:trait_count]).to eq(0)
    end

    it 'leaves other partners untouched' do
      seed('bob', :accuracy, 0.5)
      client.erase_partner!(identity: 'alice')
      result = client.fingerprint_status(partner_identity: 'bob')
      expect(result[:trait_count]).to eq(1)
    end

    it 'returns a success hash' do
      result = client.erase_partner!(identity: 'alice')
      expect(result[:erased]).to eq(true)
      expect(result[:identity]).to eq('alice')
    end

    it 'is a no-op for unknown partner and returns erased: false' do
      result = client.erase_partner!(identity: 'nobody')
      expect(result[:erased]).to eq(false)
    end
  end

  describe 'registry introspection' do
    it 'returns list of tracked partner identities' do
      seed('alice', :accuracy, 0.9)
      seed('bob', :creativity, 0.5)
      partners = client.tracked_partners
      expect(partners).to include('alice')
      expect(partners).to include('bob')
    end
  end
end
