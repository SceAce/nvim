# Avante Codex-Compatible Provider Design

## Context

The current Avante configuration selects its GitHub Copilot provider and also
declares `zbirenbaum/copilot.lua` as a dependency. During startup, Avante asks
GitHub for a Copilot token. Neovim does not inherit an HTTP or HTTPS proxy, so
that request fails with curl exit code 7. The failed asynchronous callback then
interrupts Lazy's update checker while it is waiting on a coroutine, producing
the secondary `cannot resume dead coroutine` error.

The machine already has a working Codex configuration. Its OpenAI-compatible
backend is `https://www.aivalux.com`, its model is `gpt-5.6-sol`, and it uses
the Responses API. Access to that backend and GitHub has been verified through
the local HTTP proxy at `http://127.0.0.1:7897`.

## Goals

- Make Avante use the same OpenAI-compatible backend and credential as Codex.
- Read the credential at runtime without copying it into the Neovim
  configuration, an environment variable, a log, or a committed file.
- Route every Avante model request through `http://127.0.0.1:7897`.
- Disable GitHub Copilot completely so startup performs no Copilot token
  request.
- Keep missing credentials, malformed credential files, and network failures
  local to Avante; none may abort Neovim startup.
- Add focused regression coverage for credential loading, provider merging,
  Copilot removal, and startup behavior.

## Non-goals

- Changing Codex's backend, model, credential, or configuration files.
- Supporting GitHub Copilot as a fallback provider.
- Falling back automatically to another model or API protocol.
- Exporting `OPENAI_API_KEY`, `HTTP_PROXY`, or `HTTPS_PROXY` globally.
- Enabling Avante RAG, web search, ACP providers, or unrelated AI plugins.
- Sending a content-generation request as part of verification.

## Architecture

### Credential Module

Create `lua/config/ai.lua` as the only module that knows how Codex stores its
credential. It exposes a small getter used by Avante's `parse_api_key`
callback.

The module resolves the Codex home directory from `CODEX_HOME` when that
variable is present and otherwise uses `~/.codex`. It reads `auth.json` with
Neovim's file APIs, decodes it with `vim.json.decode`, validates that
`OPENAI_API_KEY` is a non-empty string, and returns only that value. It does not
parse `config.toml`; the endpoint and model remain explicit in the Avante
configuration so provider behavior is reviewable without coupling it to the
Codex TOML schema.

The first result is cached in Lua memory for the Neovim process. Successful
lookups cache the key. Failed lookups cache the failure state and use a
once-only notification, preventing repeated file reads and repeated error
messages. Notifications identify the credential file or validation problem but
never include file contents, decoded data, or the credential. The module never
sets an environment variable and never writes to `auth.json`. After a failed
lookup, fixing the credential requires restarting Neovim so the module can
perform a fresh read.

### Avante Provider

Update `lua/plugins/avante.lua` to select a custom provider named `codex`. The
provider inherits Avante's `openai` implementation and overrides only the
settings required by the approved backend:

- endpoint: `https://www.aivalux.com`
- model: `gpt-5.6-sol`
- Responses API: enabled
- proxy: `http://127.0.0.1:7897`
- API key parser: the getter from `config.ai`

The provider retains a non-empty API key name as Avante's declaration that
authentication is required, but the custom parser supplies the value directly;
the environment is not consulted. Avante's inherited OpenAI provider therefore
builds requests for `<endpoint>/responses`, sends the key as a bearer token,
and passes the proxy only to that request.

Remove `zbirenbaum/copilot.lua` from Avante's dependency list. No Copilot
provider remains configured, selected, or used as a fallback.

### Copilot Disable Override

Replace the active setup in `lua/plugins/copilot.lua` with an explicit Lazy
plugin override that sets `zbirenbaum/copilot.lua` to `enabled = false`. This
override protects against the plugin being reintroduced transitively by the
enabled LazyVim Avante extra or another plugin spec.

Disabling the plugin rather than merely turning off its panel and inline
suggestions ensures its authentication and token-refresh code cannot run.

## Runtime Flow

1. Lazy merges the local Avante provider and Copilot-disable specifications.
2. Avante loads on `VeryLazy` and resolves the selected `codex` provider.
3. `parse_api_key` asks `config.ai` for the cached credential or performs the
   first guarded read of Codex's `auth.json`.
4. When the user sends an Avante request, the inherited OpenAI provider creates
   a Responses API request for `gpt-5.6-sol` and gives curl the provider-local
   HTTP proxy.
5. GitHub Copilot is never loaded and no request is made to
   `api.github.com/copilot_internal/v2/token`.

The credential exists only in the decoded Lua value, the module cache, and the
outgoing authorization header required for the Avante request. It is not
copied into Lazy's option table.

## Error Handling

Credential reads are protected operations. A missing file, unreadable file,
invalid JSON document, missing `OPENAI_API_KEY`, or empty/non-string key causes
the getter to return `nil` and emit one secret-free error notification. Avante
may remain loaded; its OpenAI provider already treats a `nil` key as a failed
request setup and does not send the request. Neovim startup continues.

A refused proxy, DNS failure, timeout, TLS error, or backend error is reported
for the individual Avante request. It does not switch providers, retry without
the proxy, request a Copilot token, or affect Lazy's checker coroutine.

## Verification

### Credential Tests

Add `tests/ai_config_spec.lua`. Each case points `CODEX_HOME` at a temporary
directory so the test never reads or writes the real Codex credential. The
suite uses a fake key to verify successful decoding and in-process caching,
then covers a missing file, malformed JSON, a missing field, and an invalid
field value. It also asserts that loading the key does not create or change the
`OPENAI_API_KEY` environment variable. Test output must not contain even the
fake key.

### Provider Tests

Add `tests/avante_provider_spec.lua` to inspect Lazy's merged specifications.
It verifies that:

- `codex` is the selected provider and inherits from `openai`;
- endpoint, model, Responses API, and proxy have the approved values;
- the custom key parser is present without embedding a key in the options;
- Avante no longer depends on `zbirenbaum/copilot.lua`;
- the standalone Copilot plugin specification is explicitly disabled.

The test invokes the key parser only with a temporary `CODEX_HOME` and fake
credential.

### Startup And Connectivity Checks

Run Neovim headlessly with isolated state where practical, trigger and wait
through `VeryLazy`, and capture startup messages. The check must find neither a
Copilot token URL nor curl/dead-coroutine errors and must confirm that Avante's
merged provider can be resolved without aborting startup.

Perform one authenticated, read-only model-list request to
`https://www.aivalux.com/models` through `http://127.0.0.1:7897`. The check
reads the real key dynamically and records only request success or failure; it
does not print the authorization header, key, or response body. It does not
send prompts or generate model output.

Finally, run all existing and new headless Lua tests plus Stylua checks for the
changed Lua files. No test or diagnostic command may alter the contents or
permissions of the real `~/.codex/auth.json`.
