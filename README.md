# lex-agentic-self

Domain consolidation gem for self-model, identity, metacognition, and self-awareness. Bundles 17 sub-modules into one loadable unit under `Legion::Extensions::Agentic::Self`.

## Overview

**Gem**: `lex-agentic-self`
**Version**: 0.1.13
**Namespace**: `Legion::Extensions::Agentic::Self`

## Sub-Modules

| Sub-Module | Purpose |
|---|---|
| `Self::Identity` | Behavioral fingerprint (6 dimensions, entropy anomaly) + Entra ID binding |
| `Self::Metacognition` | Second-order self-model — discovers loaded extensions, maps capabilities |
| `Self::MetacognitiveMonitoring` | Continuous confidence calibration, feeling-of-knowing |
| `Self::SelfModel` | Stable beliefs about capabilities, limitations, and values |
| `Self::SelfTalk` | IFS-inspired inner dialogue — typed turns before action |
| `Self::Reflection` | Post-tick meta-cognitive analysis — seven categories, EMA health scores |
| `Self::NarrativeArc` | McAdams narrative arc — beats, tension, resolution |
| `Self::NarrativeIdentity` | McAdams narrative identity — the agent's life story |
| `Self::NarrativeSelf` | Minimal self vs. narrative self; autobiographical episode recording |
| `Self::Architecture` | Meta-layer graph of cognitive subsystems — bottleneck detection |
| `Self::Fingerprint` | Unique cognitive style profile |
| `Self::Anchor` | Stable cognitive anchor points |
| `Self::Agency` | Sense of agency — authorship detection |
| `Self::Personality` | Big Five OCEAN trait model |
| `Self::Anosognosia` | Unawareness of own deficits |
| `Self::DefaultModeNetwork` | DMN analog — active during self-referential processing |
| `Self::RelationshipArc` | Tracks relationship milestones and bond progression with other agents; stamps NarrativeIdentity episodes on milestone events |

## Actors

- `Self::DefaultModeNetwork::Actors::Idle` — interval actor, activates DMN during idle periods
- `Self::Identity::Actors::CredentialRefresh` — interval actor, refreshes Entra ID credentials
- `Self::Identity::Actors::OrphanCheck` — runs every 14400s (4hr), checks for orphaned workers
- `Self::NarrativeIdentity::Actors::NarrativeDecay` — interval actor, decays narrative identity strength
- `Self::SelfTalk::Actors::VolumeDecay` — runs every 300s, decays inner voice volumes

## Dependencies

Runtime: `legion-cache`, `legion-crypt`, `legion-data`, `legion-json`, `legion-logging`, `legion-settings`, `legion-transport`, `faraday ~> 2.0` (for Identity Microsoft Graph API calls).

## Installation

```ruby
gem 'lex-agentic-self'
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
