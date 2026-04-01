# Changelog

## [0.1.11] - 2026-03-31

### Fixed
- `ArcEngine#to_h` now returns the last computed `relationship_health` score instead of always nil; `relationship_health()` caches result in `@last_health`
- `ArcEngine#arc_state_hash` now includes `milestones_today` key (milestones with `created_at` matching today in local time)
- `SelfTalk::Runners::SelfTalk#stub_turn_content` replaced by `mechanical_turn_content` backed by `VOICE_BANK` — produces real, meaningful content for critic/advocate/explorer/pragmatist voices; unknown types fall back to `VOICE_BANK_GENERIC`
- `SelfTalk::Runners::SelfTalk#generate_summary_for_dialogue` replaces static "Dialogue concluded" fallback with `mechanical_summary` — includes turn count, voices, and dominant position
- `Identity::Runners::Entra#rotate_client_secret` now emits a `Legion::Logging.warn` when `rotation_enabled: true` but Graph API rotation is not yet implemented, and returns `action_required` with instructions instead of a silent error

## [0.1.10] - 2026-03-31

### Added
- RelationshipArc sub-module for Phase C relational intelligence
- Constants: chapters, milestone types, health weights, chapter thresholds
- Milestone: typed data class with UUID, significance clamping, serialization
- ArcEngine: chapter progression, milestone tracking, relationship health, Apollo Local persistence
- RelationshipArc runner: record_milestone, update_arc, arc_stats with NarrativeIdentity episode stamping

## [0.1.9] - 2026-03-31

### Added
- add `PARTNER_SIGNAL_MAP` and `PARTNER_SIGNAL_THRESHOLD` constants to Personality::Helpers::Constants for partner-specific OCEAN nudges (weight 0.2 per signal)
- add `TraitModel#apply_partner_signals` to nudge extraversion, agreeableness, openness, and conscientiousness from partner engagement patterns; signals below threshold (0.3) are ignored
- wire partner signal extraction into `PersonalityStore#update` via `tick_results[:social]` reputation data (engagement frequency, direct address ratio, content diversity, consistency)
- add 16 specs covering PARTNER_SIGNAL_MAP entries, threshold gating, multi-signal application, and no observation_count side-effect

## [0.1.8] - 2026-03-30

### Fixed
- fix `NoMethodError: undefined method 'local_data_connected?'` in Identity::Fingerprint by including `Legion::Data::Helper` and adding `respond_to?` guard in `local_available?`

## [0.1.7] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.1.6] - 2026-03-26

### Changed
- fix remote_invocable? to use class method for local dispatch

## [0.1.5] - 2026-03-23

### Changed
- route llm calls through pipeline when available, add caller identity for attribution

## [0.1.4] - 2026-03-23

### Fixed
- Fix Style/RedundantParentheses on beginless ranges in Anchor constants

## [0.1.3] - 2026-03-23

### Changed
- Pipeline-aware LlmEnhancer in Reflection sub-module

## [0.1.2] - 2026-03-22

### Changed
- Add legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport as runtime dependencies
- Replace direct Legion::Logging calls with injected log helper in all runners that include Helpers::Lex
- Update spec_helper with real sub-gem helper stubs replacing hand-rolled Legion::Logging and Helpers::Lex stubs

## [0.1.1] - 2026-03-18

### Changed
- Enforce SUBSYSTEM_TYPES validation in Architecture::ArchitectureEngine#register_subsystem (raises ArgumentError)
- Enforce CONNECTION_TYPES validation in Architecture::ArchitectureEngine#create_connection (raises ArgumentError)
- Enforce EPISODE_TYPES validation in NarrativeIdentity::NarrativeEngine#add_episode (returns nil)
- Enforce THEME_TYPES validation in NarrativeIdentity::NarrativeEngine#add_theme (returns nil)

## [0.1.0] - 2026-03-18

### Added
- Initial release as domain consolidation gem
- Consolidated source extensions into unified domain gem under `Legion::Extensions::Agentic::<Domain>`
- All sub-modules loaded from single entry point
- Full spec suite with zero failures
- RuboCop compliance across all files
