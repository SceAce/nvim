# Neovim Explorer and Markdown Rendering Design

## Context

This LazyVim configuration already enables Snacks Explorer and the LazyVim
Markdown extra. The current Explorer hides dotfiles and files ignored by Git.
The Markdown extra includes `render-markdown.nvim`, but formula rendering has
not been configured explicitly. The shortcut reference also contains stale
Neo-tree and Telescope names even though the active configuration uses Snacks.

The machine runs Neovim 0.12.3 on Arch Linux. `libtexprintf` is installed and
provides `/usr/bin/utftex`. The `latex`, `markdown`, and `markdown_inline`
Treesitter parsers are currently installed.

## Goals

- Keep `<leader>E` opening Snacks Explorer at the current working directory.
- Show dotfiles and Git-ignored files and directories by default.
- Preserve Git status and untracked-file indicators in Explorer.
- Render inline and block LaTeX formulas as Unicode inside Neovim.
- Keep LaTeX source directly editable in Insert mode.
- Separate Explorer and Markdown rendering configuration by responsibility.
- Reconcile the complete existing shortcut reference with runtime mappings.

## Non-goals

- Replacing Snacks Explorer, `render-markdown.nvim`, or the existing browser
  preview plugin.
- Rendering formulas as images or opening a browser for formula rendering.
- Turning `keymap.md` into an exhaustive manual for every plugin command.
- Refactoring configuration unrelated to Explorer, Markdown rendering, or the
  shortcut reference.

## Configuration Structure

### Explorer

Create `lua/plugins/explorer.lua` as the sole owner of Explorer-specific Snacks
Picker options. Configure the `explorer` source with:

- `hidden = true`
- `ignored = true`
- `git_status = true`
- `git_untracked = true`
- a left sidebar layout

Move the existing Explorer layout override out of `lua/plugins/ui.lua` so that
the general UI module retains only dashboard, statusline, and other shared UI
settings. LazyVim continues to provide `<leader>e` for the project root and
`<leader>E` for the current working directory.

Explorer keeps its built-in controls. `H` temporarily toggles dotfiles, `I`
temporarily toggles Git-ignored entries, and `[g` / `]g` navigate Git changes.
The `.git` directory is intentionally visible because both hidden and ignored
entries are enabled without an exclusion rule.

### Markdown Rendering

Create `lua/plugins/markdown_render.lua` for display-only Markdown behavior.
Keep `lua/plugins/markdown_writer.lua` responsible for authoring helpers such
as Aerial, image insertion, and browser preview.

The rendering module extends the Treesitter parser list with `latex` so a fresh
installation reproduces the current parser state. It explicitly configures
`render-markdown.nvim` to:

- enable LaTeX rendering;
- use `utftex` as the formula converter;
- render in the plugin's normal-mode view while leaving Insert mode as source;
- place block-formula output above the source range so multiline Unicode
  fractions, integrals, and similar constructs are supported.

Inline `$...$` formulas render in place. Block `$$...$$` formulas use virtual
lines. LazyVim's existing `<leader>um` mapping continues to toggle the rendered
Markdown view. The existing `<leader>mp` mapping continues to toggle the
private-browser preview and remains independent of in-editor formula rendering.

If `utftex` is unavailable, the plugin must remain non-fatal and leave readable
LaTeX source. The shortcut reference will name `libtexprintf` as the formula
rendering prerequisite and point to the render-markdown health check for
diagnosis.

## Shortcut Reference

Reconcile `keymap.md` against mappings registered by the running configuration,
including filetype-local mappings after opening a Markdown buffer. The audit
covers every existing document section and will:

- rename Neo-tree references to Snacks Explorer;
- rename Telescope references to Snacks Picker where applicable;
- remove documented mappings that are no longer registered;
- correct mappings whose mode, command, scope, or description has changed;
- add important active mappings omitted from the current reference;
- document Explorer toggles and Git navigation;
- document `<leader>um`, formula behavior, and the `utftex` prerequisite.

The document remains a curated shortcut reference. Commands without mappings
and obscure plugin-internal actions are outside its scope.

## Verification

1. Start Neovim headlessly with isolated state and cache directories and assert
   that the full configuration loads without Lua errors.
2. Inspect the merged Snacks Explorer source and assert that `hidden`,
   `ignored`, `git_status`, and `git_untracked` are all true.
3. Confirm that `utftex` is executable, the LaTeX Treesitter parser is
   available, and the merged render-markdown LaTeX configuration is enabled,
   uses `utftex`, and places block output above the source.
4. Open a temporary Markdown fixture containing inline math, a fraction, and an
   integral; wait for rendering and verify that render-markdown creates formula
   extmarks or virtual lines without reporting errors.
5. Capture global, Snacks Explorer, and Markdown-buffer mappings from the
   runtime configuration and compare each documented section with those maps.
6. Run Stylua checks on changed Lua files and validate the Markdown table
   structure.

Verification fixes remain scoped to the files and behavior described here.
