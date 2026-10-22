# init-agents

[![CI](https://github.com/Alias23/init-agents/actions/workflows/ci.yml/badge.svg)](https://github.com/Alias23/init-agents/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Generador de estructura **Spec-Driven Development (SDD)** para proyectos gestionados con OpenCode V2.

`init-agents` se ejecuta dentro de la raíz de un proyecto y crea la documentación, las plantillas, la skill y los agentes/comandos necesarios para trabajar con el flujo:

```text
Constitución → Spec → Clarificación → Plan → Tareas → Implementación → Validación → Cambio
```

## Características

- Un solo script Bash, sin dependencias externas.
- Genera 24 archivos (23 con `--no-guide`).
- Preguntas interactivas con valores detectados automáticamente.
- Flags para automatizar la generación.
- Idempotente: se puede ejecutar varias veces sin romper nada.
- Nunca borra archivos.
- No instala dependencias, no inicializa git y no modifica la configuración global de OpenCode.
- No crea `opencode.json`.
- Incluye suite de pruebas, integración continua y licencia MIT.

## Requisitos

- Bash 4 o superior.
- Linux o macOS.
- `curl` o `git` para instalar.
- OpenCode V2 para usar los agentes, comandos y la skill generados.
- Opcional para desarrollo: `shellcheck` y Python 3 con PyYAML.

En macOS, si Bash es demasiado antiguo:

```bash
brew install bash
```

Añade el Bash instalado al `PATH` o invócalo por su ruta absoluta:

```bash
export PATH="$(brew --prefix)/bin:$PATH"
```

## Instalación

> Repositorio: [Alias23/init-agents](https://github.com/Alias23/init-agents).

### Desde una release (recomendada)

```bash
mkdir -p ~/.local/bin
curl -fsSL https://github.com/Alias23/init-agents/releases/latest/download/init-agents -o ~/.local/bin/init-agents
chmod +x ~/.local/bin/init-agents
```

Asegúrate de que `~/.local/bin` esté en el `PATH`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Para zsh, usa `~/.zshrc`. Comprueba la instalación:

```bash
init-agents --version
```

Si aún no hay una release publicada, descarga el script desde `main`:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/Alias23/init-agents/main/init-agents -o ~/.local/bin/init-agents
chmod +x ~/.local/bin/init-agents
```

### Verificación de la descarga (opcional)

Las releases incluyen un archivo de checksum:

```bash
curl -fsSL https://github.com/Alias23/init-agents/releases/latest/download/init-agents.sha256 -o /tmp/init-agents.sha256
(cd ~/.local/bin && sha256sum -c /tmp/init-agents.sha256)
```

En macOS, usa `shasum -a 256 -c /tmp/init-agents.sha256`.

### Desde el código fuente

```bash
git clone https://github.com/Alias23/init-agents.git
cd init-agents
./init-agents --help
```

Para instalarlo desde el clon:

```bash
install -m 755 init-agents ~/.local/bin/init-agents
```

El proyecto no incluye un `install.sh`: la instalación consiste en descargar el script y darle permisos de ejecución.

## Uso

```bash
cd mi-proyecto
init-agents
```

El script pregunta los datos del proyecto, muestra un resumen y pide confirmación antes de escribir.

### Ejemplo

```text
$ init-agents

Configuración del proyecto (Enter para aceptar el valor entre corchetes):
  Nombre del proyecto [mi-proyecto]:
  Descripción breve [Proyecto gestionado con Spec-Driven Development (SDD).]:
  Stack principal [HTML/CSS/JS]:
  Comando de tests [no definido]: node --test
  Persistencia de datos [localStorage]:
  Verificación visual [manual en el navegador]:
  Idioma del código [inglés]:
  Idioma de documentación e interfaz [español]:

Resumen:
  Proyecto:        mi-proyecto
  Descripción:     Proyecto gestionado con Spec-Driven Development (SDD).
  Stack:           HTML/CSS/JS
  Tests:           node --test
  Persistencia:    localStorage
  Verificación:    manual en el navegador
  Código:          inglés
  Documentación:   español

¿Generar 24 archivos? [S/n]:
```

Enter acepta el valor por defecto. Para usar los valores detectados sin preguntar:

```bash
init-agents --yes
```

Si no hay terminal interactiva, el script usa los valores detectados y no pide confirmación.

## Opciones

| Opción | Descripción |
|---|---|
| `--name TEXTO` | Nombre del proyecto. |
| `--description TEXTO` | Descripción breve del proyecto. |
| `--stack TEXTO` | Stack principal. |
| `--test-command COMANDO` | Comando de tests. |
| `--data-store TEXTO` | Persistencia de datos. |
| `--ui-check TEXTO` | Cómo verificar la interfaz. |
| `--code-language IDIOMA` | Idioma del código. |
| `--doc-language IDIOMA` | Idioma de documentación e interfaz. |
| `-y, --yes` | Usa los valores detectados y no pide confirmación. |
| `-f, --force` | Sobrescribe archivos existentes creando backup. |
| `--append-agents` | Añade el bloque SDD a un `AGENTS.md` existente. |
| `--no-guide` | No genera `docs/sdd.md`; el flujo queda en la skill `sdd`. |
| `-n, --dry-run` | Muestra lo que haría sin escribir nada. |
| `--list` | Lista los archivos que generaría. |
| `-h, --help` | Muestra la ayuda. |
| `-v, --version` | Muestra la versión. |

`--force` y `--append-agents` son mutuamente excluyentes.

Los flags fijan los valores por defecto. Sin `--yes`, las preguntas siguen apareciendo con esos valores entre corchetes; con `--yes`, se aplican directamente los valores detectados y los flags indicados.

## Estructura generada

```text
mi-proyecto/
├── AGENTS.md
├── MEMORY.md
├── docs/
│   ├── README.md
│   ├── constitution.md
│   └── sdd.md
├── specs/
│   ├── README.md
│   └── _template/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
├── tests/
│   └── README.md
├── .agents/
│   └── skills/
│       └── sdd/
│           └── SKILL.md
└── .opencode/
    ├── agents/
    │   ├── coordinator.md
    │   ├── planner.md
    │   ├── implementer.md
    │   └── reviewer.md
    └── commands/
        ├── sdd-constitution.md
        ├── sdd-spec.md
        ├── sdd-clarify.md
        ├── sdd-plan.md
        ├── sdd-tasks.md
        ├── sdd-implement.md
        ├── sdd-validate.md
        ├── sdd-change.md
        └── sdd-status.md
```

Con `--no-guide` se omite `docs/sdd.md` (23 archivos). `docs/README.md`, `AGENTS.md` y `specs/README.md` ajustan sus referencias para apuntar solo a la skill `sdd`. Si `docs/sdd.md` ya existía, no se borra.

## Detección automática

El script intenta rellenar los valores por defecto:

| Dato | Detección |
|---|---|
| Nombre | Nombre de la carpeta actual. |
| Stack | `package.json`, `pyproject.toml`, `requirements.txt`, `setup.py`, `go.mod`, `Cargo.toml` o `index.html`. |
| Tests | Script `test` de `package.json` (`npm`, `pnpm`, `yarn` o `bun`), `pytest`, `go test ./...` o `cargo test`; si no se detecta, `no definido`. |
| Persistencia | `localStorage`, `SQLite`, `PostgreSQL` o “la persistencia del proyecto”. |
| Verificación visual | “manual en el navegador” si existe `index.html`; si no, “no aplica”. |
| Idiomas | Código en inglés; documentación e interfaz en español. |

Puedes corregir cualquier valor en las preguntas o con los flags.

## Flujo SDD generado

| Fase | Comando | Agente |
|---|---|---|
| Constitución | `/sdd-constitution` | `planner` |
| Spec | `/sdd-spec 001-nombre idea inicial` | `planner` |
| Clarificación | `/sdd-clarify 001-nombre` | `reviewer` |
| Plan | `/sdd-plan 001-nombre` | `planner` |
| Tareas | `/sdd-tasks 001-nombre` | `planner` |
| Implementación | `/sdd-implement 001-nombre T1` | `implementer` |
| Validación | `/sdd-validate 001-nombre` | `reviewer` |
| Cambio | `/sdd-change 001-nombre nuevo requisito` | `planner` |
| Estado | `/sdd-status 001-nombre` | `planner` |

Los comandos `sdd-spec`, `sdd-change` e `sdd-implement` usan argumentos posicionales:

- `$1`: carpeta de la spec, por ejemplo `001-heat-map`.
- `$2`: idea inicial, nuevo requisito o tarea.

## Agentes generados

| Agente | Modo | Rol |
|---|---|---|
| `coordinator` | `primary` | Orquesta el flujo completo y transmite el contexto entre fases. No edita archivos. |
| `planner` | `all` | Redacta la constitución, la spec, el plan y las tareas. No toca código. |
| `implementer` | `all` | Implementa una sola tarea, con tests primero, y se detiene. |
| `reviewer` | `all` | Revisa la spec como QA y valida la implementación RF por RF. No modifica archivos. |

`planner`, `implementer` y `reviewer` usan `mode: all` para que los comandos puedan ejecutarse en la sesión actual y hacer preguntas de una en una.

## Placeholders

| Placeholder | Origen | Valor por defecto |
|---|---|---|
| `{{PROJECT_NAME}}` | Pregunta o `--name` | Nombre de la carpeta actual |
| `{{PROJECT_DESCRIPTION}}` | Pregunta o `--description` | “Proyecto gestionado con Spec-Driven Development (SDD).” |
| `{{STACK}}` | Pregunta o `--stack` | Detectado |
| `{{TEST_COMMAND}}` | Pregunta o `--test-command` | Detectado |
| `{{DATA_STORE}}` | Pregunta o `--data-store` | “la persistencia del proyecto” |
| `{{UI_CHECK}}` | Pregunta o `--ui-check` | “manual en el navegador” o “no aplica” |
| `{{CODE_LANGUAGE}}` | Pregunta o `--code-language` | “inglés” |
| `{{DOC_LANGUAGE}}` | Pregunta o `--doc-language` | “español” |
| `{{DATE}}` | Automático | Fecha actual (`YYYY-MM-DD`) |

El script sustituye estos valores en todos los archivos generados.

## Comportamiento con archivos existentes

Por defecto, si un archivo ya existe:

- No se sobrescribe.
- Se informa por pantalla.
- Se continúa con el resto.

Opciones:

```bash
init-agents --force          # sobrescribe con backup .bak.<timestamp>
init-agents --append-agents  # añade el bloque SDD a un AGENTS.md existente
```

`--append-agents` usa marcadores para no duplicar el contenido:

```markdown
<!-- init-agents:sdd:start -->
...
<!-- init-agents:sdd:end -->
```

Si los marcadores ya existen, no se añade nada. Si `AGENTS.md` no existe, se crea completo.

## Seguridad

- Se niega a ejecutarse en `/` o en `$HOME`.
- No borra archivos ni directorios.
- No ejecuta `sudo`.
- No hace peticiones de red.
- `--dry-run` no crea ni modifica nada.
- `--force` crea una copia de seguridad antes de sobrescribir.

## Limitaciones

- No instala dependencias del proyecto.
- No configura servidores MCP, como Chrome DevTools.
- No crea `opencode.json` ni cambia el agente por defecto.
- No inicializa git.
- No genera código de aplicación.
- `AGENTS.md`, `MEMORY.md` y `tests/README.md` son plantillas: hay que completar la información específica del proyecto.
- `docs/constitution.md` es un punto de partida; revísalo antes de usarlo.
- La verificación visual se define con `{{UI_CHECK}}`; si el proyecto no tiene interfaz, indica “no aplica”.
- Con `--no-guide` no se genera `docs/sdd.md`; el flujo completo queda en la skill `sdd`.

## Primeros pasos después de generar

1. Revisa `docs/constitution.md` y `AGENTS.md`.
2. Completa `MEMORY.md` con el estado y las decisiones del proyecto.
3. Ajusta `tests/README.md` a la estrategia de pruebas real.
4. Abre OpenCode y ejecuta:

```text
/sdd-spec 001-mi-idea <descripción de la idea>
```

5. Consulta la fase actual con:

```text
/sdd-status 001-mi-idea
```

Sin `opencode.json`, OpenCode no cambia el agente por defecto: selecciona `coordinator` manualmente o usa los comandos `/sdd-*`.

## Solución de problemas

### `init-agents: command not found`

Añade `~/.local/bin` al `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### `Permission denied`

Comprueba los permisos del comando instalado:

```bash
chmod +x ~/.local/bin/init-agents
```

O reinstálalo desde el clon:

```bash
install -m 755 init-agents ~/.local/bin/init-agents
```

### La descarga de la release devuelve 404

Comprueba que el repositorio y la release existan. Si todavía no has publicado una release, usa la descarga desde `main` o clona el repositorio:

```bash
git clone https://github.com/Alias23/init-agents.git
cd init-agents
./init-agents --help
```

### `Se requiere Bash 4 o superior`

macOS incluye Bash 3.2. Instala una versión moderna y úsala:

```bash
brew install bash
export PATH="$(brew --prefix)/bin:$PATH"
bash --version
```

También puedes ejecutar el script con la ruta absoluta del Bash instalado:

```bash
"$(brew --prefix)/bin/bash" /ruta/a/init-agents --help
```

### No se han creado algunos archivos

Ya existían. Usa:

```bash
init-agents --force
```

o, solo para `AGENTS.md`:

```bash
init-agents --append-agents
```

### No se ha generado `docs/sdd.md`

Si has usado `--no-guide`, es intencionado. Ejecuta de nuevo sin ese flag para crearlo (los archivos existentes se omiten):

```bash
init-agents
```

Si el archivo existe pero quieres regenerarlo:

```bash
init-agents --force
```

### El script se niega a ejecutarse

Está pensado para la raíz de un proyecto. No lo ejecutes en `/` ni en `$HOME`:

```bash
cd mi-proyecto
init-agents
```

### OpenCode no muestra los agentes o comandos

Comprueba que existen:

```bash
ls .opencode/agents/
ls .opencode/commands/
```

Revisa que el frontmatter YAML sea válido y reinicia la sesión si hace falta.

### OpenCode no encuentra la skill `sdd`

Debe existir:

```text
.agents/skills/sdd/SKILL.md
```

OpenCode V2 descubre `.agents/skills` como ubicación de compatibilidad.

### No aparece `coordinator` por defecto

El script no crea `opencode.json`. Selecciona `coordinator` manualmente o usa los comandos `/sdd-*`.

### El comando de tests no existe o no está definido

Vuelve a generarlo con el comando correcto:

```bash
init-agents --force --test-command "npm test"
```

Si no hay tests automáticos, edita `AGENTS.md`, `docs/constitution.md` y los agentes para indicar la verificación manual.

### `--force` y `--append-agents` a la vez

Son mutuamente excluyentes. Elige uno:

```bash
init-agents --force
# o
init-agents --append-agents
```

## Desarrollo

Requisitos para desarrollar:

- Bash 4 o superior.
- `shellcheck` para lint.
- Python 3 con PyYAML para validar el frontmatter. Si no está disponible, la suite omite esas comprobaciones.

Validación y pruebas:

```bash
bash -n init-agents
bash -n test/init-agents-test.sh
shellcheck init-agents test/init-agents-test.sh
bash test/init-agents-test.sh
```

La suite crea un directorio temporal, prueba la generación completa, la idempotencia, `--force`, `--dry-run`, `--append-agents`, `--no-guide`, la detección automática, los caracteres especiales y el modo interactivo cuando el sistema lo permite. El directorio temporal se elimina al terminar.

Prueba manual rápida:

```bash
tmp="$(mktemp -d)"
cd "$tmp"
/path/to/init-agents --yes
find . -maxdepth 4 -type f | sort
```

Sustituye `/path/to/init-agents` por la ruta real del script.

### CI

`.github/workflows/ci.yml` ejecuta ShellCheck y la suite en Ubuntu y macOS. En macOS instala Bash 5 con Homebrew para que el generador tenga la versión requerida.

`.github/workflows/release.yml` crea la release y el checksum al subir un tag `v*`.

### Estructura del repositorio

```text
init-agents/
├── init-agents
├── README.md
├── LICENSE
├── CHANGELOG.md
├── .gitignore
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── release.yml
└── test/
    └── init-agents-test.sh
```

`test/` es la suite del generador. La carpeta `tests/` es la que se genera dentro de cada proyecto.

## Desinstalación

Elimina el comando:

```bash
rm ~/.local/bin/init-agents
```

Los archivos generados en cada proyecto se eliminan manualmente. El script no lleva un registro global de lo que ha creado.

## Versión

`1.0.0`

`init-agents` usa Semantic Versioning. Las releases se publican como tags `v1.0.0`, `v1.1.0`, etc. La compatibilidad con OpenCode V2 es independiente de la versión del generador.

Consulta [CHANGELOG.md](CHANGELOG.md) para el historial de cambios.

## Publicar en GitHub

Cuando quieras publicar el repositorio:

```bash
git init
git add init-agents README.md LICENSE CHANGELOG.md .gitignore .github test
git commit -m "feat: publicar init-agents 1.0.0"
git branch -M main
git remote add origin https://github.com/Alias23/init-agents.git
git push -u origin main
git tag -a v1.0.0 -m "init-agents 1.0.0"
git push origin v1.0.0
```

Al subir el tag, el workflow `Release` crea la release con `init-agents` y `init-agents.sha256`.

Estos comandos no se ejecutan automáticamente: el repositorio local no se inicializa ni se sube a GitHub hasta que tú lo decidas.

## Licencia

MIT. Consulta [LICENSE](LICENSE).
