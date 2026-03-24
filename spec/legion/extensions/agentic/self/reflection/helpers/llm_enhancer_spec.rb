# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Self::Reflection::Helpers::LlmEnhancer do
  let(:enhancer_mod) { described_class }

  describe '.pipeline_available?' do
    it 'returns false when GaiaCaller is not defined' do
      begin
        hide_const('Legion::LLM::Pipeline::GaiaCaller')
      rescue StandardError
        nil
      end
      expect(described_class.pipeline_available?).to be false
    end

    it 'returns false when pipeline_enabled? is false' do
      stub_const('Legion::LLM::Pipeline::GaiaCaller', double)
      stub_const('Legion::LLM', double(respond_to?: true, pipeline_enabled?: false))
      expect(described_class.pipeline_available?).to be false
    end

    it 'returns true when GaiaCaller defined and pipeline enabled' do
      gaia_caller_mod = Module.new
      pipeline_mod    = Module.new
      pipeline_mod.const_set(:GaiaCaller, gaia_caller_mod)
      llm_mod = Module.new
      llm_mod.const_set(:Pipeline, pipeline_mod)
      llm_mod.define_singleton_method(:respond_to?) { |*| true }
      llm_mod.define_singleton_method(:pipeline_enabled?) { true }
      stub_const('Legion::LLM', llm_mod)
      expect(described_class.pipeline_available?).to be true
    end

    it 'returns false on any error' do
      stub_const('Legion::LLM', double)
      allow(Legion::LLM).to receive(:respond_to?).and_raise(StandardError)
      expect(described_class.pipeline_available?).to be false
    end
  end

  describe '.enhance' do
    it 'uses GaiaCaller when pipeline is available' do
      allow(enhancer_mod).to receive(:available?).and_return(true)
      allow(enhancer_mod).to receive(:pipeline_available?).and_return(true)

      mock_response = double(message: { content: 'reflected' })
      gaia_caller_mod = Module.new
      gaia_caller_mod.define_singleton_method(:chat) { |**| mock_response }
      pipeline_mod = Module.new
      pipeline_mod.const_set(:GaiaCaller, gaia_caller_mod)
      llm_mod = Module.new
      llm_mod.const_set(:Pipeline, pipeline_mod)
      stub_const('Legion::LLM', llm_mod)

      expect(gaia_caller_mod).to receive(:chat)
        .with(hash_including(phase: 'reflection'))
        .and_return(mock_response)

      result = enhancer_mod.enhance('reflect on this', phase: 'reflection')
      expect(result).to eq('reflected')
    end

    it 'falls back to legacy chat when pipeline unavailable' do
      allow(enhancer_mod).to receive(:available?).and_return(true)
      allow(enhancer_mod).to receive(:pipeline_available?).and_return(false)

      mock_chat = double(ask: double(content: 'legacy reflected'))
      stub_const('Legion::LLM', double(chat: mock_chat))

      result = enhancer_mod.enhance('reflect on this', phase: 'reflection')
      expect(result).to eq('legacy reflected')
    end

    it 'returns nil when not available' do
      allow(enhancer_mod).to receive(:available?).and_return(false)
      expect(enhancer_mod.enhance('hello')).to be_nil
    end
  end

  describe '.available?' do
    context 'when Legion::LLM is not defined' do
      it 'returns a falsy value' do
        # Legion::LLM is not defined in the test environment
        expect(described_class.available?).to be_falsy
      end
    end

    context 'when Legion::LLM is defined but not started' do
      before do
        stub_const('Legion::LLM', double(respond_to?: true, started?: false))
      end

      it 'returns false' do
        expect(described_class.available?).to be false
      end
    end

    context 'when Legion::LLM is started' do
      before do
        stub_const('Legion::LLM', double(respond_to?: true, started?: true))
      end

      it 'returns true' do
        expect(described_class.available?).to be true
      end
    end

    context 'when an error is raised' do
      before do
        stub_const('Legion::LLM', double)
        allow(Legion::LLM).to receive(:respond_to?).and_raise(StandardError)
      end

      it 'returns false' do
        expect(described_class.available?).to be false
      end
    end
  end

  describe '.enhance_reflection' do
    let(:fake_response) do
      double(content: <<~TEXT)
        EMOTION: My arousal is elevated at 0.7 while stability holds at 0.8, suggesting urgency without destabilization.
        PREDICTION: Confidence at 65% with a declining trend and 3 pending predictions signals I am losing ground in forward modeling.
        MEMORY: Memory health appears nominal with no concerning decay patterns detected this cycle.
        TRUST: Trust scores remain stable with no significant drift observed.
        CURIOSITY: Curiosity intensity is moderate; resolution rates suggest effective exploration.
        IDENTITY: Identity entropy is within expected bounds; no drift detected.
      TEXT
    end
    let(:fake_chat) { double }
    let(:monitors_data) do
      [
        {
          category:       :emotional_stability,
          observation:    'original',
          severity:       :notable,
          metrics:        { stability: 0.8 },
          recommendation: :no_action
        },
        {
          category:       :prediction_calibration,
          observation:    'original',
          severity:       :notable,
          metrics:        { confidence: 0.65 },
          recommendation: :increase_curiosity
        }
      ]
    end
    let(:health_scores) do
      {
        prediction_calibration:  0.65,
        curiosity_effectiveness: 0.8,
        emotional_stability:     0.8,
        trust_drift:             1.0,
        memory_health:           0.95,
        cognitive_load:          0.9,
        mode_patterns:           1.0
      }
    end

    before do
      stub_const('Legion::LLM', double)
      allow(Legion::LLM).to receive(:chat).and_return(fake_chat)
      allow(fake_chat).to receive(:with_instructions)
      allow(fake_chat).to receive(:ask).and_return(fake_response)
    end

    it 'returns observations hash with at least some categories' do
      result = described_class.enhance_reflection(
        monitors_data: monitors_data,
        health_scores: health_scores
      )
      expect(result).to be_a(Hash)
      expect(result[:observations]).to be_a(Hash)
      expect(result[:observations]).not_to be_empty
    end

    it 'parses per-category observation text' do
      result = described_class.enhance_reflection(
        monitors_data: monitors_data,
        health_scores: health_scores
      )
      expect(result[:observations][:emotional_stability]).to include('arousal')
      expect(result[:observations][:prediction_calibration]).to include('Confidence')
    end

    context 'when LLM returns nil content' do
      before { allow(fake_chat).to receive(:ask).and_return(double(content: nil)) }

      it 'returns nil' do
        result = described_class.enhance_reflection(
          monitors_data: monitors_data,
          health_scores: health_scores
        )
        expect(result).to be_nil
      end
    end

    context 'when LLM raises an error' do
      before { allow(fake_chat).to receive(:ask).and_raise(StandardError, 'LLM timeout') }

      it 'returns nil and logs a warning' do
        expect(Legion::Logging).to receive(:warn).with(/enhance_reflection failed/)
        result = described_class.enhance_reflection(
          monitors_data: monitors_data,
          health_scores: health_scores
        )
        expect(result).to be_nil
      end
    end
  end

  describe '.reflect_on_dream' do
    let(:fake_response) do
      double(content: <<~TEXT)
        REFLECTION: The dream cycle surfaced 3 unresolved traces and resolved 1 contradiction. Memory consolidation is progressing normally with agenda items focused on identity coherence.
      TEXT
    end
    let(:fake_chat) { double }
    let(:dream_results) do
      {
        memory_audit:             { decayed: 5, pruned: 2, unresolved_count: 3 },
        contradiction_resolution: { detected: 2, resolved: 1 },
        agenda_formation:         { agenda_items: 4 }
      }
    end

    before do
      stub_const('Legion::LLM', double)
      allow(Legion::LLM).to receive(:chat).and_return(fake_chat)
      allow(fake_chat).to receive(:with_instructions)
      allow(fake_chat).to receive(:ask).and_return(fake_response)
    end

    it 'returns a reflection string' do
      result = described_class.reflect_on_dream(dream_results: dream_results)
      expect(result).to be_a(Hash)
      expect(result[:reflection]).to be_a(String)
      expect(result[:reflection]).not_to be_empty
    end

    it 'includes dream cycle content in the reflection' do
      result = described_class.reflect_on_dream(dream_results: dream_results)
      expect(result[:reflection]).to include('unresolved traces')
    end

    context 'when LLM returns nil content' do
      before { allow(fake_chat).to receive(:ask).and_return(double(content: nil)) }

      it 'returns nil' do
        result = described_class.reflect_on_dream(dream_results: dream_results)
        expect(result).to be_nil
      end
    end

    context 'when LLM raises an error' do
      before { allow(fake_chat).to receive(:ask).and_raise(StandardError, 'model error') }

      it 'returns nil and logs a warning' do
        expect(Legion::Logging).to receive(:warn).with(/reflect_on_dream failed/)
        result = described_class.reflect_on_dream(dream_results: dream_results)
        expect(result).to be_nil
      end
    end
  end
end
