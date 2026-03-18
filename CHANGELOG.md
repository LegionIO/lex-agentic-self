# Changelog

## [Unreleased]

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
