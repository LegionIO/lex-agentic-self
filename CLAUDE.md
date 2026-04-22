# lex-agentic-self

**Parent**: `../CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for self-model, identity, metacognition, and self-awareness. Bundles 17 sub-modules into one loadable unit under `Legion::Extensions::Agentic::Self`.

**Gem**: `lex-agentic-self`
**Version**: 0.1.13
**Namespace**: `Legion::Extensions::Agentic::Self`

## Sub-Modules

| Sub-Module | Source Gem | Purpose | Runner Methods |
|---|---|---|---|
| `Self::Identity` | `lex-identity` | Behavioral fingerprint (6 dimensions, entropy anomaly) + Entra ID binding | `identity_status`, `refresh_credentials`, `orphan_check` |
| `Self::Metacognition` | `lex-metacognition` | Second-order self-model — discovers loaded extensions, maps capabilities | `metacognition_status`, `registry_status` |
| `Self::MetacognitiveMonitoring` | `lex-metacognitive-monitoring` | Continuous confidence calibration, feeling-of-knowing | `metacognitive_monitoring_status`, `calibrate` |
| `Self::SelfModel` | `lex-self-model` | Stable beliefs about capabilities, limitations, and values | `self_model_status`, `update_capability` |
| `Self::SelfTalk` | `lex-self-talk` | IFS-inspired inner dialogue — typed turns before action | `self_talk_status`, `inner_dialogue` |
| `Self::Reflection` | `lex-reflection` | Post-tick meta-cognitive analysis — seven categories, EMA health scores | `reflect`, `reflection_status` |
| `Self::NarrativeArc` | `lex-cognitive-narrative-arc` | McAdams narrative arc — beats, tension, resolution | `narrative`, `narrative_arc_status` |
| `Self::NarrativeIdentity` | `lex-narrative-identity` | McAdams narrative identity — the agent's life story | `narrative_identity_status`, `record_episode` |
| `Self::NarrativeSelf` | `lex-narrative-self` | Minimal self vs. narrative self; autobiographical episode recording | `record_narrative_self_episode`, `recent_episodes`, `significant_episodes`, `episodes_by_type`, `create_thread`, `strongest_threads`, `timeline`, `self_summary`, `update_narrative_self`, `narrative_self_stats` |
| `Self::Architecture` | `lex-cognitive-architecture` | Meta-layer graph of cognitive subsystems — bottleneck detection | `cognitive_architecture_status`, `map_subsystems` |
| `Self::Fingerprint` | `lex-cognitive-fingerprint` | Unique cognitive style profile | `cognitive_fingerprint_status` |
| `Self::Anchor` | `lex-cognitive-anchor` | Stable cognitive anchor points | `cognitive_anchor_status`, `add_anchor` |
| `Self::Agency` | `lex-agency` | Sense of agency — authorship detection | `agency_status`, `record_outcome` |
| `Self::Personality` | `lex-personality` | Big Five OCEAN trait model | `personality_status`, `update_trait` |
| `Self::Anosognosia` | `lex-anosognosia` | Unawareness of own deficits | `anosognosia_status`, `detect_deficit` |
| `Self::DefaultModeNetwork` | `lex-default-mode-network` | DMN analog — active during self-referential processing | `default_mode_network_status`, `wander` |
| `Self::RelationshipArc` | `lex-relationship-arc` | Tracks relationship milestones and bond progression with other agents; stamps NarrativeIdentity episodes on milestone events | `record_milestone`, `update_arc`, `arc_stats` |

## Metacognition Namespace Note

After consolidation, `Metacognition` is at `Legion::Extensions::Agentic::Self::Metacognition`, not at the old `Legion::Extensions::Metacognition`. `SelfModel.extension_loaded?` handles both flat and `Agentic::*` nested paths to detect loaded extensions regardless of layout.

## Actors

| Actor | Interval | Target Method |
|---|---|---|
| `Self::DefaultModeNetwork::Actors::Idle` | interval | `DefaultModeNetwork#wander` |
| `Self::Identity::Actors::CredentialRefresh` | interval | `Identity#refresh_credentials` |
| `Self::Identity::Actors::OrphanCheck` | 14400s (4hr) | `Identity#orphan_check` |
| `Self::NarrativeIdentity::Actors::NarrativeDecay` | interval | `NarrativeIdentity#decay_narratives` |
| `Self::SelfTalk::Actors::VolumeDecay` | 300s | `SelfTalk#decay_volumes` |

## Dependencies

| Gem | Purpose |
|---|---|
| `legion-cache` >= 1.3.11 | Cache access |
| `legion-crypt` >= 1.4.9 | Encryption/Vault |
| `legion-data` >= 1.4.17 | DB (Identity local migration `20260316000030_create_fingerprint`) |
| `legion-json` >= 1.2.1 | JSON serialization |
| `legion-logging` >= 1.3.2 | Logging |
| `legion-settings` >= 1.3.14 | Settings |
| `legion-transport` >= 1.3.9 | AMQP |
| `faraday` ~> 2.0 | HTTP client for `Self::Identity` Microsoft Graph API calls |

## Key Architecture Notes

- `Self::NarrativeSelf#record_narrative_self_episode` is the canonical method name (previously misnamed in older docs). It stores autobiographical episodes with `episode_type`, `domain`, `significance`, `emotional_valence`, and `tags`.
- `Self::RelationshipArc#record_milestone` automatically stamps a `NarrativeIdentity` episode when a relationship milestone is recorded (via `stamp_narrative_episode`). The cross-module dependency is guarded with `defined?`.
- `Self::Identity` has a local DB migration for the fingerprint table.

## Tick Integration

- `Self::Identity` maps to `identity_entropy_check` tick phase
- `Self::Reflection` maps to `post_tick_reflection` tick phase

## Development

```bash
bundle install   # includes faraday ~> 2.0 for identity/graph_client
bundle exec rspec        # 0 failures
bundle exec rubocop      # 0 offenses
```
