# Phoenix Playwrithing — Agent + MCP + Playwright Demo App

A small Phoenix LiveView application built exclusively for demonstrating AI agents
using MCP and Playwright to explore, test, and debug web UIs.

> Playwright is expected to be installed **globally** on your machine.
> Test instructions live as YAML files under `docs/flows/` — no TypeScript specs in this repo.

---

## Flows

| Route | Description | Status |
|---|---|---|
| `/` | Home — links to all flows | — |
| `/qualifier` | Debt eligibility form | Has YAML spec |
| `/contact-preference` | Contact channel & time picker | YAML spec — no test yet |
| `/offer` | Plan selector | YAML spec with seeded bug |
| `/contracts` | Service agreement — accept terms | Enrollment step |

---

## Running the app locally

```bash
cd phoenix_playwrithing
mix setup       # install deps + build assets (first time)
mix phx.server  # start on http://localhost:4000
```

---

## Setup: Playwright MCP

Playwright MCP es un servidor MCP oficial de Microsoft que conecta agentes de IA
directamente al navegador mediante el árbol de accesibilidad de Playwright.
No requiere capturas de pantalla ni modelos de visión — opera sobre estructura pura.

> No se instala como paquete del proyecto. Se ejecuta bajo demanda con `npx`.

### Requisitos

- Node.js 18 o superior (`node --version`)
- Browsers de Playwright instalados:

```bash
npx playwright install chromium
```

---

## Conectar Playwright MCP a Cursor

Hay dos formas. Elige la que mejor se adapte a tu flujo.

### Opción A — Config global en Cursor (recomendada para la demo)

1. Abre **Cursor Settings** (`Cmd + ,`)
2. Ve a la sección **MCP** (o **Tools & Integrations → MCP**)
3. Haz clic en **"Add new MCP Server"** o **"Edit"** si ya existe uno
4. Pega el siguiente JSON:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser", "chrome",
        "--test-id-attribute", "data-testid"
      ]
    }
  }
}
```

5. Guarda y **reinicia Cursor**
6. Verifica en **Settings → MCP** que el servidor `playwright` aparece activo (punto verde)

> El modo headed (browser visible) es el **comportamiento por defecto** del MCP.
> Para correr sin ventana usa `--headless`. Para la demo, no agregues ningún flag
> extra — el browser aparece automáticamente.

### Opción B — Config por proyecto (`.cursor/mcp.json`)

Crea el archivo `.cursor/mcp.json` en la raíz del proyecto:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser", "chrome",
        "--test-id-attribute", "data-testid"
      ]
    }
  }
}
```

Reinicia Cursor. Esta config viaja con el repo.

### Verificar que funciona

Abre el panel de chat de Cursor (Agent mode) y escribe:

```
Open http://localhost:4000 in the browser and take a snapshot of the page.
```

Deberías ver el browser abrirse y Cursor describir el árbol de accesibilidad de la home.

---

## Agente Claude para la demo en vivo

Para presentaciones donde quieras mostrar el agente corriendo en vivo,
Claude Code CLI + Playwright MCP es la combinación más clara para una audiencia.

### Instalación de Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

### Registrar Playwright MCP en Claude

```bash
claude mcp add playwright npx @playwright/mcp@latest -- \
  --browser chrome \
  --test-id-attribute data-testid
```

Verifica que quedó registrado:

```bash
claude mcp list
```

### Correr el agente en vivo

Con la app corriendo (`mix phx.server`), lanza Claude en modo interactivo:

```bash
claude
```

Luego, en el prompt de Claude, pega instrucciones como estas durante la presentación:

**Momento 1 — explorar la app:**
```
Read docs/flows/qualifier.yaml and then open http://localhost:4000/qualifier.
Explore the page and confirm that all data-testid selectors described in the YAML
are present in the DOM.
```

**Momento 2 — ejecutar el flujo happy path:**
```
Using the qualifier flow spec in docs/flows/qualifier.yaml, navigate the form,
fill it with valid data (debt_amount: 15000), submit it, and assert that the
success message "Your profile has been accepted" is visible.
```

**Momento 3 — explorar un flujo sin spec:**
```
Navigate to http://localhost:4000/contact-preference. Explore all interactive
elements and their data-testid attributes. Then update docs/flows/contact_preference.yaml
with a complete steps block covering the happy path and validation errors.
```

**Momento 4 — detectar el bug:**
```
Navigate to http://localhost:4000/offer. Select the Premium plan.
Assert that the element [data-testid="premium-support-message"] is visible
and contains "Priority support included". If the assertion fails, read
docs/flows/offer_bug_notes.yaml and the source file
lib/phoenix_playwrithing_web/live/offer_live.ex, identify the root cause,
and propose the fix.
```

### Configuración alternativa: Claude Desktop

Si prefieres usar Claude Desktop (interfaz visual), edita el archivo de config:

```bash
# macOS
open ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Agrega:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser", "chrome",
        "--test-id-attribute", "data-testid"
      ]
    }
  }
}
```

Reinicia Claude Desktop. El agente tendrá acceso al browser desde la interfaz de chat.

---

## How tests work in this project

Tests are described as **YAML instruction files** under `docs/flows/`.
An agent reads a YAML file, navigates the app with Playwright (global install),
and either executes assertions or generates new tests.

### YAML spec format

```yaml
id: qualifier
flow: qualifier
host: localhost
path: /qualifier

steps:
  - action: navigate
    url: "http://localhost:4000/qualifier"
  - action: fill
    selector: "[data-testid='input-full-name']"
    value: "Jane Doe"
  - action: fill
    selector: "[data-testid='input-email']"
    value: "jane@example.com"
  - action: fill
    selector: "[data-testid='input-debt-amount']"
    value: "15000"
  - action: click
    selector: "[data-testid='submit-button']"

assertions:
  - selector: "[data-testid='success-message']"
    contains: "Your profile has been accepted"
```

### Running with global Playwright

```bash
# Ensure Playwright is globally available
playwright --version

# Run a flow by pointing Playwright to the spec (or via agent/MCP)
playwright test docs/flows/qualifier.yaml
```

---

## Demo script (10-15 min)

### 1. "Here is the app"
- `mix phx.server`
- Open [http://localhost:4000](http://localhost:4000)
- Show the three flow cards

### 2. "Here is the YAML spec"
- Open `docs/flows/qualifier.yaml`
- Explain fields, steps, and `data-testid` selectors

### 3. "Agent explores and generates a test"
- Point to `docs/flows/contact_preference.yaml` — no steps yet
- Agent navigates `/contact-preference`, inspects `data-testid` attributes,
  and produces a new YAML spec with steps + assertions

### 4. "Agent executes the test"
- Agent runs the generated steps via global Playwright
- Assertions pass

### 5. "Agent finds a bug in /offer"
- Agent navigates `/offer`, selects the Premium plan
- Asserts `[data-testid="premium-support-message"]` is visible — **fails**
- Agent reads `docs/flows/offer_bug_notes.yaml` and the LiveView source
- Identifies `"premium-plan"` vs `"premium"` mismatch and proposes the fix

---

## Project structure

```
phoenix_playwrithing/
├── lib/phoenix_playwrithing_web/live/
│   ├── home_live.ex
│   ├── qualifier_live.ex
│   ├── contact_preference_live.ex
│   └── offer_live.ex              ← bug is here (~line 75)
└── docs/flows/
    ├── qualifier.yaml             ← spec for flow 1
    ├── contact_preference.yaml    ← spec for flow 2 (no steps yet)
    └── offer_bug_notes.yaml       ← documents the seeded bug
```

---

## The seeded bug

**File:** `lib/phoenix_playwrithing_web/live/offer_live.ex`

```heex
<%!-- BUG: checks "premium-plan" but stored value is "premium" --%>
<div :if={@selected_plan == "premium-plan"} data-testid="premium-support-message">
  Priority support included
</div>
```

**Fix:** change `"premium-plan"` → `"premium"`.

Full details: `docs/flows/offer_bug_notes.yaml`.
