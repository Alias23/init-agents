#!/usr/bin/env bash
# Suite de pruebas de init-agents.
#
# Uso:
#   bash test/init-agents-test.sh
#
# Variables opcionales:
#   SCRIPT=/ruta/a/init-agents
#   BASH_BIN=/ruta/a/bash
#
# La suite escribe únicamente en un directorio temporal y lo elimina al salir.
# shellcheck disable=SC2015,SC2181
set -uo pipefail

SCRIPT="${SCRIPT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/init-agents}"
BASH_BIN="${BASH_BIN:-bash}"

if [[ ! -f "$SCRIPT" ]]; then
  printf 'ERROR: no existe %s\n' "$SCRIPT" >&2
  exit 2
fi

if ! "$BASH_BIN" -c '((BASH_VERSINFO[0] >= 4))' 2>/dev/null; then
  printf 'ERROR: se requiere Bash 4 o superior. Usa BASH_BIN=/ruta/a/bash.\n' >&2
  exit 2
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/init-agents-test.XXXXXX")" || {
  printf 'ERROR: no se pudo crear el directorio temporal.\n' >&2
  exit 2
}
FAIL_FILE="$BASE/.failures"
: >"$FAIL_FILE"
trap 'rm -rf "$BASE"' EXIT

pass() { printf 'PASS: %s\n' "$*"; }
fail() {
  printf 'FAIL: %s\n' "$*"
  printf '%s\n' "$*" >>"$FAIL_FILE"
}

check_status() {
  local label="$1"
  local status="$2"
  if [[ "$status" -eq 0 ]]; then
    pass "$label"
  else
    fail "$label (status $status)"
  fi
}

run_tool() {
  "$BASH_BIN" "$SCRIPT" "$@"
}

if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
  YAML_AVAILABLE=true
else
  YAML_AVAILABLE=false
  printf 'SKIP: frontmatter YAML (PyYAML no disponible)\n'
fi

check_yaml() {
  python3 - <<'PY'
import pathlib
import sys

import yaml

ok = True
for p in sorted(pathlib.Path('.').rglob('*.md')):
    text = p.read_text(encoding='utf-8')
    if not text.startswith('---\n'):
        continue
    try:
        end = text.index('\n---\n', 4)
        yaml.safe_load(text[4:end])
    except Exception as exc:
        print(f'YAML ERROR {p}: {exc}')
        ok = False
sys.exit(0 if ok else 1)
PY
}

# 1. Sintaxis
"$BASH_BIN" -n "$SCRIPT"
check_status "bash -n" "$?"

# 2. Generación completa con flags
mkdir -p "$BASE/fresh"
(
  cd "$BASE/fresh" || exit 1
  run_tool --yes \
    --name "Suite Project" \
    --description "Descripción de prueba." \
    --stack "Test Stack" \
    --test-command "npm test" \
    --data-store "SQLite" \
    --ui-check "Chrome" \
    --code-language "inglés" \
    --doc-language "español" >"$BASE/fresh.log" 2>&1
)
check_status "generación completa" "$?"

(
  cd "$BASE/fresh" || exit 1
  count="$(find . -type f | wc -l | tr -d ' ')"
  [[ "$count" == "24" ]] && pass "24 archivos generados" || fail "se esperaban 24 archivos, hay $count"
  grep -q '^# AGENTS.md — Suite Project$' AGENTS.md && pass "AGENTS.md con nombre" || fail "AGENTS.md sin nombre"
  grep -q '^## Reglas$' AGENTS.md && pass "AGENTS.md incluye ## Reglas" || fail "AGENTS.md sin ## Reglas"
  grep -q '^## Stack y estructura$' AGENTS.md && pass "AGENTS.md incluye Stack" || fail "AGENTS.md sin Stack"
  grep -q '^## Memoria$' AGENTS.md && pass "AGENTS.md incluye Memoria" || fail "AGENTS.md sin Memoria"
  grep -q '^## Verificación$' AGENTS.md && pass "AGENTS.md incluye Verificación" || fail "AGENTS.md sin Verificación"
  grep -q '^## Estado actual$' MEMORY.md && pass "MEMORY.md incluye Estado actual" || fail "MEMORY.md sin Estado actual"
  grep -q '^## Decisiones (y por qué)$' MEMORY.md && pass "MEMORY.md incluye Decisiones" || fail "MEMORY.md sin Decisiones"
  grep -q '^## Aprendizajes y errores a evitar$' MEMORY.md && pass "MEMORY.md incluye Aprendizajes" || fail "MEMORY.md sin Aprendizajes"
  grep -q '^## Próximos pasos$' MEMORY.md && pass "MEMORY.md incluye Próximos pasos" || fail "MEMORY.md sin Próximos pasos"
  grep -q '^## Paso 1: Constitución$' docs/sdd.md && pass "sdd.md incluye Paso 1" || fail "sdd.md sin Paso 1"
  grep -q '^## Paso 7: Validación$' docs/sdd.md && pass "sdd.md incluye Paso 7" || fail "sdd.md sin Paso 7"
  grep -q '^## Mantenimiento: cambios de requisitos$' docs/sdd.md && pass "sdd.md incluye cambios" || fail "sdd.md sin cambios"
  grep -q '^Estado: borrador$' specs/_template/spec.md && pass "plantilla spec con estado" || fail "plantilla spec sin estado"
  count_principles="$(grep -c '^[1-6]\. \*\*' docs/constitution.md)"
  [[ "$count_principles" == "6" ]] && pass "constitución con 6 principios" || fail "constitución con $count_principles principios"
  grep -q '^name: sdd$' .agents/skills/sdd/SKILL.md && pass "skill con name: sdd" || fail "skill sin name"
  grep -q '^description: >-$' .agents/skills/sdd/SKILL.md && pass "skill con description multilínea" || fail "skill sin description multilínea"
  grep -q '^agent: planner$' .opencode/commands/sdd-spec.md && pass "sdd-spec usa planner" || fail "sdd-spec no usa planner"
  grep -q '^subagent: false$' .opencode/commands/sdd-spec.md && pass "sdd-spec con subagent false" || fail "sdd-spec sin subagent false"
  # shellcheck disable=SC2016 # $2 es literal del comando SDD.
  grep -q 'Idea inicial: \$2' .opencode/commands/sdd-spec.md && pass "sdd-spec usa \$2" || fail "sdd-spec no usa \$2"
  # shellcheck disable=SC2016 # $2 es literal del comando SDD.
  grep -q 'tarea `\$2`' .opencode/commands/sdd-implement.md && pass "sdd-implement usa \$2" || fail "sdd-implement no usa \$2"
  grep -q '^agent: implementer$' .opencode/commands/sdd-implement.md && pass "sdd-implement usa implementer" || fail "sdd-implement no usa implementer"
  grep -q '^agent: reviewer$' .opencode/commands/sdd-validate.md && pass "sdd-validate usa reviewer" || fail "sdd-validate no usa reviewer"
  grep -q "resource: 'npm test\\*'" .opencode/agents/reviewer.md && pass "reviewer permite npm test" || fail "reviewer no permite npm test"
  if grep -RIn -E '\{\{[A-Z_]+\}\}' AGENTS.md MEMORY.md docs specs tests .agents .opencode >"$BASE/placeholders.txt" 2>/dev/null; then
    fail "quedan placeholders sin sustituir"
    cat "$BASE/placeholders.txt"
  else
    pass "sin placeholders sin sustituir"
  fi
  if $YAML_AVAILABLE; then
    check_yaml
    check_status "frontmatter YAML válido" "$?"
  else
    printf 'SKIP: frontmatter YAML (PyYAML no disponible)\n'
  fi
)

# 3. Idempotencia
(
  cd "$BASE/fresh" || exit 1
  run_tool --yes --name "Otro" --test-command "npm test" >"$BASE/rerun.log" 2>&1
)
check_status "segunda ejecución" "$?"

(
  cd "$BASE/fresh" || exit 1
  grep -q 'Creados:[[:space:]]*0' "$BASE/rerun.log" && pass "rerun no crea archivos" || fail "rerun creó archivos"
  grep -q 'Omitidos:[[:space:]]*24' "$BASE/rerun.log" && pass "rerun omite los 24" || fail "rerun no omite los 24"
  grep -q '^# AGENTS.md — Suite Project$' AGENTS.md && pass "rerun no cambia AGENTS.md" || fail "rerun cambió AGENTS.md"
)

# 4. --force con backups
(
  cd "$BASE/fresh" || exit 1
  run_tool --yes --name "Forced" --test-command "npm test" --force >"$BASE/force.log" 2>&1
)
check_status "--force" "$?"

(
  cd "$BASE/fresh" || exit 1
  backups="$(find . -name '*.bak.*' | wc -l | tr -d ' ')"
  [[ "$backups" == "24" ]] && pass "--force crea 24 backups" || fail "--force creó $backups backups"
  grep -q 'Sobrescritos:[[:space:]]*24' "$BASE/force.log" && pass "--force sobrescribe 24" || fail "--force no sobrescribe 24"
  grep -q '^# AGENTS.md — Forced$' AGENTS.md && pass "--force actualiza AGENTS.md" || fail "--force no actualiza AGENTS.md"
)

# 5. --dry-run en directorio limpio
mkdir -p "$BASE/dry"
(
  cd "$BASE/dry" || exit 1
  run_tool --yes --name "Dry" --dry-run >"$BASE/dry.log" 2>&1
)
check_status "--dry-run" "$?"

(
  cd "$BASE/dry" || exit 1
  count="$(find . -type f | wc -l | tr -d ' ')"
  [[ "$count" == "0" ]] && pass "--dry-run no escribe" || fail "--dry-run escribió $count archivos"
  grep -q '\[dry-run\] crearía AGENTS.md' "$BASE/dry.log" && pass "--dry-run informa" || fail "--dry-run no informa"
  grep -q 'Simulación completada' "$BASE/dry.log" && pass "--dry-run termina con aviso" || fail "--dry-run sin aviso final"
)

# 6. --append-agents
mkdir -p "$BASE/append"
(
  cd "$BASE/append" || exit 1
  printf '# Existing\n\nCustom.\n' > AGENTS.md
  run_tool --yes --append-agents --name "Append" --test-command "npm test" >"$BASE/append1.log" 2>&1
)
check_status "--append-agents" "$?"

(
  cd "$BASE/append" || exit 1
  starts="$(grep -c 'init-agents:sdd:start' AGENTS.md)"
  ends="$(grep -c 'init-agents:sdd:end' AGENTS.md)"
  [[ "$starts" == "1" && "$ends" == "1" ]] && pass "append: un solo bloque" || fail "append: bloques start=$starts end=$ends"
  grep -q '^# Existing$' AGENTS.md && pass "append conserva contenido" || fail "append perdió contenido"
  grep -q '^Custom\.$' AGENTS.md && pass "append conserva texto" || fail "append perdió texto"
  grep -q 'Anexados:[[:space:]]*1' "$BASE/append1.log" && pass "append cuenta 1" || fail "append no cuenta 1"
  run_tool --yes --append-agents --name "Append" --test-command "npm test" >"$BASE/append2.log" 2>&1
  starts="$(grep -c 'init-agents:sdd:start' AGENTS.md)"
  ends="$(grep -c 'init-agents:sdd:end' AGENTS.md)"
  [[ "$starts" == "1" && "$ends" == "1" ]] && pass "append idempotente" || fail "append duplicado start=$starts end=$ends"
  grep -q 'Anexados:[[:space:]]*0' "$BASE/append2.log" && pass "segundo append no anexa" || fail "segundo append anexa"
  [[ "$(tail -c 1 AGENTS.md | wc -l | tr -d ' ')" == "1" ]] && pass "append termina en salto de línea" || fail "append sin salto final"
)

# 7. --append-agents sin AGENTS.md
mkdir -p "$BASE/append-missing"
(
  cd "$BASE/append-missing" || exit 1
  run_tool --yes --append-agents --name "Append Missing" >/dev/null 2>&1
)
check_status "append sin AGENTS.md" "$?"

(
  cd "$BASE/append-missing" || exit 1
  grep -q '^# AGENTS.md — Append Missing$' AGENTS.md && pass "append crea AGENTS.md completo" || fail "append no crea AGENTS.md"
)

# 8. --list
mkdir -p "$BASE/list"
(
  cd "$BASE/list" || exit 1
  run_tool --list >"$BASE/list.txt" 2>&1
)
check_status "--list" "$?"

(
  lines="$(wc -l <"$BASE/list.txt" | tr -d ' ')"
  [[ "$lines" == "24" ]] && pass "--list muestra 24" || fail "--list muestra $lines"
  grep -q '^\.opencode/agents/coordinator\.md$' "$BASE/list.txt" && pass "--list incluye coordinator" || fail "--list sin coordinator"
  count="$(find "$BASE/list" -type f | wc -l | tr -d ' ')"
  [[ "$count" == "0" ]] && pass "--list no escribe" || fail "--list escribió $count archivos"
)

# 8b. --no-guide
mkdir -p "$BASE/no-guide"
(
  cd "$BASE/no-guide" || exit 1
  run_tool --yes --no-guide --name "No Guide" --test-command "npm test" >"$BASE/no-guide.log" 2>&1
)
check_status "--no-guide" "$?"

(
  cd "$BASE/no-guide" || exit 1
  count="$(find . -type f | wc -l | tr -d ' ')"
  [[ "$count" == "23" ]] && pass "--no-guide genera 23 archivos" || fail "--no-guide generó $count archivos"
  [[ ! -e docs/sdd.md ]] && pass "--no-guide omite docs/sdd.md" || fail "--no-guide generó docs/sdd.md"
  if grep -q 'docs/sdd.md' AGENTS.md docs/README.md specs/README.md 2>/dev/null; then
    fail "--no-guide deja referencias a docs/sdd.md"
  else
    pass "--no-guide ajusta referencias"
  fi
  if grep -RIn -E '\{\{[A-Z_]+\}\}' AGENTS.md MEMORY.md docs specs tests .agents .opencode >"$BASE/no-guide-placeholders.txt" 2>/dev/null; then
    fail "--no-guide deja placeholders"
    cat "$BASE/no-guide-placeholders.txt"
  else
    pass "--no-guide sin placeholders"
  fi
  if $YAML_AVAILABLE; then
    check_yaml
    check_status "--no-guide frontmatter YAML" "$?"
  else
    printf 'SKIP: --no-guide frontmatter YAML (PyYAML no disponible)\n'
  fi
)

(
  run_tool --list --no-guide >"$BASE/list-no-guide.txt" 2>&1
)
check_status "--list --no-guide" "$?"

(
  lines="$(wc -l <"$BASE/list-no-guide.txt" | tr -d ' ')"
  [[ "$lines" == "23" ]] && pass "--list --no-guide muestra 23" || fail "--list --no-guide muestra $lines"
  if grep -q '^docs/sdd\.md$' "$BASE/list-no-guide.txt"; then
    fail "--list --no-guide incluye docs/sdd.md"
  else
    pass "--list --no-guide omite docs/sdd.md"
  fi
)

# 9. --help y --version
run_tool --help | grep -q -- '--description' && pass "--help muestra --description" || fail "--help sin --description"
run_tool --help | grep -q -- '--list' && pass "--help muestra --list" || fail "--help sin --list"
run_tool --help | grep -q -- '--no-guide' && pass "--help muestra --no-guide" || fail "--help sin --no-guide"
version="$(run_tool --version 2>&1)"
expected_version="$(awk -F'"' '/^VERSION=/{print $2; exit}' "$SCRIPT")"
[[ "$version" == "$expected_version" ]] && pass "--version ($expected_version)" || fail "--version devuelve '$version' (se esperaba '$expected_version')"

# 10. Rechazo de / y $HOME
if ( cd / && run_tool --list >/dev/null 2>&1 ); then
  fail "no rechaza /"
else
  pass "rechaza /"
fi
if ( cd "$HOME" && run_tool --list >/dev/null 2>&1 ); then
  fail "no rechaza \$HOME"
else
  pass "rechaza \$HOME"
fi

# 11. Detección automática
mkdir -p "$BASE/detect"
(
  cd "$BASE/detect" || exit 1
  printf '{"name":"x","scripts":{"test":"node --test"}}\n' > package.json
  printf '<html></html>\n' > index.html
  run_tool --yes >"$BASE/detect.log" 2>&1
)
check_status "detección" "$?"

(
  cd "$BASE/detect" || exit 1
  grep -q 'Stack:[[:space:]]*Node.js/JavaScript' "$BASE/detect.log" && pass "detecta stack" || fail "no detecta stack"
  grep -q 'Tests:[[:space:]]*npm test' "$BASE/detect.log" && pass "detecta npm test" || fail "no detecta npm test"
  grep -q 'Verificación:[[:space:]]*manual en el navegador' "$BASE/detect.log" && pass "detecta UI" || fail "no detecta UI"
  grep -q 'Persistencia:[[:space:]]*la persistencia del proyecto' "$BASE/detect.log" && pass "detecta persistencia por defecto" || fail "persistencia inesperada"
)

# 12. Caracteres especiales y YAML
mkdir -p "$BASE/special"
(
  cd "$BASE/special" || exit 1
  run_tool --yes --name 'R&D' --description 'A & B' --test-command "echo 'a&b'" >/dev/null 2>&1
)
check_status "caracteres especiales" "$?"

(
  cd "$BASE/special" || exit 1
  grep -q '^# AGENTS.md — R&D$' AGENTS.md && pass "nombre con &" || fail "nombre con & mal"
  grep -q '^A & B$' AGENTS.md && pass "descripción con &" || fail "descripción con & mal"
  if $YAML_AVAILABLE; then
    python3 - <<'PY'
import pathlib
import sys

import yaml

p = pathlib.Path('.opencode/agents/reviewer.md')
text = p.read_text(encoding='utf-8')
end = text.index('\n---\n', 4)
data = yaml.safe_load(text[4:end])
resources = [item['resource'] for item in data['permissions'] if item.get('action') == 'shell']
if "echo 'a&b'*" not in resources:
    print('resources:', resources)
    sys.exit(1)
PY
    check_status "reviewer YAML con comilla y &" "$?"
  else
    printf 'SKIP: reviewer YAML (PyYAML no disponible)\n'
  fi
)

# 13. Opciones incompatibles
if run_tool --yes --force --append-agents >/dev/null 2>&1; then
  fail "--force y --append-agents no fallan"
else
  pass "--force y --append-agents son excluyentes"
fi

# 14. Opción desconocida
if run_tool --no-guia >/dev/null 2>&1; then
  fail "--no-guia no falla"
else
  pass "opción desconocida falla"
fi

# 15. --dry-run con --force
mkdir -p "$BASE/dry-force"
(
  cd "$BASE/dry-force" || exit 1
  printf 'x\n' > AGENTS.md
  run_tool --yes --force --dry-run >"$BASE/dry-force.log" 2>&1
)
check_status "dry-run force" "$?"

(
  cd "$BASE/dry-force" || exit 1
  backups="$(find . -name '*.bak.*' | wc -l | tr -d ' ')"
  [[ "$backups" == "0" ]] && pass "dry-run force sin backups" || fail "dry-run force creó $backups backups"
  [[ "$(cat AGENTS.md)" == "x" ]] && pass "dry-run force no modifica" || fail "dry-run force modificó"
  grep -q 'sobrescribiría AGENTS.md' "$BASE/dry-force.log" && pass "dry-run force informa" || fail "dry-run force no informa"
)

# 16. --dry-run con --append-agents
mkdir -p "$BASE/dry-append"
(
  cd "$BASE/dry-append" || exit 1
  printf '# Existing\n' > AGENTS.md
  before="$(cksum AGENTS.md)"
  run_tool --yes --append-agents --dry-run >"$BASE/dry-append.log" 2>&1
  after="$(cksum AGENTS.md)"
  [[ "$before" == "$after" ]] && pass "dry-run append no modifica" || fail "dry-run append modificó"
  grep -q 'anexaría el bloque SDD' "$BASE/dry-append.log" && pass "dry-run append informa" || fail "dry-run append no informa"
)

# 17. Interactivo (solo Linux con script compatible)
if [[ "$(uname -s)" == "Linux" ]] && command -v script >/dev/null 2>&1 && [[ "$BASH_BIN" != *" "* && "$SCRIPT" != *" "* ]]; then
  mkdir -p "$BASE/interactive"
  (
    cd "$BASE/interactive" || exit 1
    printf 'Interactivo\nDescripción.\nStack\nnode --test\nlocalStorage\nChrome\ninglés\nespañol\ny\n' | script -qec "$BASH_BIN $SCRIPT" /dev/null >"$BASE/interactive.log" 2>&1
  )
  check_status "modo interactivo" "$?"
  (
    cd "$BASE/interactive" || exit 1
    grep -q '^# AGENTS.md — Interactivo$' AGENTS.md && pass "interactivo usa nombre" || fail "interactivo no usa nombre"
    grep -q 'Descripción\.' AGENTS.md && pass "interactivo usa descripción" || fail "interactivo no usa descripción"
  )
else
  printf 'SKIP: modo interactivo (solo Linux con script y rutas sin espacios)\n'
fi

# 18. Sin TTY usa valores detectados
mkdir -p "$BASE/notty"
(
  cd "$BASE/notty" || exit 1
  run_tool < /dev/null >"$BASE/notty.log" 2>&1
)
check_status "sin TTY" "$?"

(
  cd "$BASE/notty" || exit 1
  grep -q '^# AGENTS.md — notty$' AGENTS.md && pass "sin TTY usa nombre detectado" || fail "sin TTY no usa nombre detectado"
  grep -q 'Tests:[[:space:]]*no definido' "$BASE/notty.log" && pass "sin TTY avisa de tests" || fail "sin TTY no avisa de tests"
)

printf '\n'
if [[ -s "$FAIL_FILE" ]]; then
  printf 'HAY PRUEBAS FALLIDAS:\n'
  cat "$FAIL_FILE"
  exit 1
else
  printf 'TODAS LAS PRUEBAS PASARON\n'
  exit 0
fi
