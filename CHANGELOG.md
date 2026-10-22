# Changelog

Todas las versiones notables de `init-agents` se documentan en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y el versionado sigue [Semantic Versioning](https://semver.org/lang/es/).

## [1.0.0] - 2026-10-22

### Añadido

- Generador Bash de estructura Spec-Driven Development para OpenCode V2.
- 24 archivos por defecto y 23 con `--no-guide`.
- Agentes `coordinator`, `planner`, `implementer` y `reviewer`.
- Comandos `/sdd-constitution`, `/sdd-spec`, `/sdd-clarify`, `/sdd-plan`,
  `/sdd-tasks`, `/sdd-implement`, `/sdd-validate`, `/sdd-change` y
  `/sdd-status`.
- Skill `sdd` y guía completa `docs/sdd.md`.
- Detección automática de stack, tests, persistencia e interfaz.
- Modo interactivo, `--yes`, `--force`, `--append-agents`, `--dry-run`,
  `--no-guide` y `--list`.
- Backups `.bak.<timestamp>` antes de sobrescribir.
- Suite de pruebas y CI para Linux y macOS.
- Documentación en español y licencia MIT.
