# lex-agentic-self

**Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for self-model, identity, metacognition, and self-awareness. Bundles 16 source extensions into one loadable unit under `Legion::Extensions::Agentic::Self`.

**Gem**: `lex-agentic-self`
**Version**: 0.1.1
**Namespace**: `Legion::Extensions::Agentic::Self`

## Sub-Modules

| Sub-Module | Source Gem | Purpose |
|---|---|---|
| `Self::Identity` | `lex-identity` | Behavioral fingerprint (6 dimensions, entropy anomaly) + Entra ID binding |
| `Self::Metacognition` | `lex-metacognition` | Second-order self-model — discovers loaded extensions, maps capabilities |
| `Self::MetacognitiveMonitoring` | `lex-metacognitive-monitoring` | Continuous confidence calibration, feeling-of-knowing |
| `Self::SelfModel` | `lex-self-model` | Stable beliefs about capabilities, limitations, and values |
| `Self::SelfTalk` | `lex-self-talk` | IFS-inspired inner dialogue — typed turns before action |
| `Self::Reflection` | `lex-reflection` | Post-tick meta-cognitive analysis — seven categories, EMA health scores |
| `Self::NarrativeArc` | `lex-cognitive-narrative-arc` | McAdams narrative arc — beats, tension, resolution |
| `Self::NarrativeIdentity` | `lex-narrative-identity` | McAdams narrative identity — the agent's life story |
| `Self::NarrativeSelf` | `lex-narrative-self` | Minimal self vs. narrative self |
| `Self::Architecture` | `lex-cognitive-architecture` | Meta-layer graph of cognitive subsystems — bottleneck detection |
| `Self::Fingerprint` | `lex-cognitive-fingerprint` | Unique cognitive style profile |
| `Self::Anchor` | `lex-cognitive-anchor` | Stable cognitive anchor points |
| `Self::Agency` | `lex-agency` | Sense of agency — authorship detection |
| `Self::Personality` | `lex-personality` | Big Five OCEAN trait model |
| `Self::Anosognosia` | `lex-anosognosia` | Unawareness of own deficits |
| `Self::DefaultModeNetwork` | `lex-default-mode-network` | DMN analog — active during self-referential processing |

## Metacognition Namespace Note

After consolidation, `Metacognition` is at `Legion::Extensions::Agentic::Self::Metacognition`, not at the old `Legion::Extensions::Metacognition`. `SelfModel.extension_loaded?` handles both flat and `Agentic::*` nested paths to detect loaded extensions regardless of layout.

## Actors

- `Self::Identity::Actors::OrphanCheck` — runs every 14400s (4hr), checks for orphaned workers
- `Self::SelfTalk::Actors::VolumeDecay` — runs every 300s, decays inner voice volumes

## Tick Integration

- `Self::Identity` maps to `identity_entropy_check` tick phase
- `Self::Reflection` maps to `post_tick_reflection` tick phase

## Development

```bash
bundle install   # includes faraday ~> 2.0 for identity/graph_client
bundle exec rspec        # 1760 examples, 0 failures
bundle exec rubocop      # 0 offenses
```
