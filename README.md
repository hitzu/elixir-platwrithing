# Phoenix Playwrithing — Agent + MCP + Playwright Demo App

A small Phoenix LiveView application built exclusively for demonstrating AI agents
using MCP and Playwright to explore, test, and debug web UIs.

> Playwright is expected to be installed **globally** on your machine.
> Test instructions live as YAML files under `docs/flows/` — no TypeScript specs in this repo.

---

## Flows

| Route                 | Description                      | Status                    |
| --------------------- | -------------------------------- | ------------------------- |
| `/`                   | Home — links to all flows        | —                         |
| `/qualifier`          | Debt eligibility form            | Has YAML spec             |
| `/contact-preference` | Contact channel & time picker    | YAML spec — no test yet   |
| `/offer`              | Plan selector                    | `docs/flows/offer.yaml`   |
| `/contracts`          | Service agreement — accept terms | Enrollment step           |

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
        "--browser",
        "chrome",
        "--test-id-attribute",
        "data-testid"
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
        "--browser",
        "chrome",
        "--test-id-attribute",
        "data-testid"
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

Luego, en el prompt de Claude, pega instrucciones como estas durante la presentación.

Usa siempre el **MCP de Playwright** para abrir la app, interactuar con la UI y comprobar el DOM; la lectura de YAML/archivos complementa, pero no sustituye al navegador.

### Plantilla reutilizable — ejecutar happy path desde un flow YAML

Sustituye `<FLOW_FILE>` por el nombre del archivo bajo `docs/flows/` (por ejemplo `qualifier.yaml` o `contact_preference.yaml`). Vuelve a pegar este mismo bloque cada vez que quieras demostrar otro flujo ya especificado.

```
Read docs/flows/<FLOW_FILE>.yaml. Using the Playwright MCP browser tools, open the
URL derived from that spec (host + path), follow the steps for the happy path with
the field values the YAML implies (e.g. debt_amount: 15000 for qualifier), submit,
and assert every success outcome described in the spec (e.g. visible text
"Your profile has been accepted" when the spec says so).
```

**Momento 1 — explorar la app (spec existente):**

```
Read docs/flows/qualifier.yaml. With Playwright MCP, open http://localhost:4000/qualifier
and execute the test.
```

**Momento 2 — explorar un flujo sin spec y generar YAML:**

```
With Playwright MCP, navigate to http://localhost:4000/contact-preference.
Explore every interactive control and its data-testid attributes. Then create or
update docs/flows/contact_preference.yaml with a complete steps block for the
happy path and for validation errors, matching the project’s YAML format under
docs/flows/.
```

**Momento 2a — mismo flujo “ejecutar YAML”, archivo nuevo:**

Tras generar `contact_preference.yaml`, **repite la plantilla** sustituyendo el archivo:

```
Read docs/flows/contact_preference.yaml. Using the Playwright MCP browser tools,
open the URL from the spec, execute the happy path per the steps, and assert the
success criteria defined in that YAML.
```

**Momento 3 — spec como “prueba que debería pasar”:**

```
Read docs/flows/offer.yaml. Using Playwright MCP, open the URL from the spec
and run the steps you need from that file. If something fails, investigate and
propose a concrete code fix.
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
        "--browser",
        "chrome",
        "--test-id-attribute",
        "data-testid"
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

### 5. "Agent runs the offer spec — Premium-only regression"

- Agent reads `docs/flows/offer.yaml` and runs `steps.basic_banner` / `steps.standard_banner` — **pass**
- Each plan has a detail `alert` under the grid; Basic and Standard use the correct `:if` plan ids
- Agent runs `steps.premium_banner` — **fails** until `premium-support-message` uses `"premium"` not `"premium-plan"`
- Agent proposes the fix in `offer_live.ex` so behavior matches the spec

---

## Project structure

```
phoenix_playwrithing/
├── lib/phoenix_playwrithing_web/live/
│   ├── home_live.ex
│   ├── qualifier_live.ex
│   ├── contact_preference_live.ex
│   └── offer_live.ex              ← plan banners (intentional Premium :if drift)
└── docs/flows/
    ├── qualifier.yaml             ← spec for flow 1
    ├── contact_preference.yaml    ← spec for flow 2 (no steps yet)
    └── offer.yaml                 ← offer flow / regression baseline
```

---

## The seeded bug (Premium detail banner)

[`docs/flows/offer.yaml`](docs/flows/offer.yaml) describes three detail banners under the plan grid:
`basic-support-message`, `standard-support-message`, and `premium-support-message`. Basic and
Standard match `phx-value-plan` ids and **work**. Premium intentionally uses a wrong `:if` so
agents can see **two plans show an extra alert, one does not**.

**File:** `lib/phoenix_playwrithing_web/live/offer_live.ex` — `premium-support-message` block.

**Fix:** `@selected_plan == "premium-plan"` → `@selected_plan == "premium"`.

To restore the failing demo after fixing, temporarily reintroduce `"premium-plan"` on that `:if`.
