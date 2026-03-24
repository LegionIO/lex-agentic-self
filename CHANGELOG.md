# Changelog

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
