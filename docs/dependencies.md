# Components and dependencies

The repository separates reusable tools, mathematical libraries and experiment evidence.

| Component | Location | Runtime dependencies |
| --- | --- | --- |
| Compiler extraction, natural-language translation/review, checked migration | `src/lift_tools/` | Python; Lean/Lake for compilation; a JSON model command for translation |
| Evidence validation, tables and offline demos | `src/lift_artifacts/` | Python; plotting dependencies for figures |
| ReasLib and original clients | `examples/` | Each project's pinned Lean/Mathlib environment |
| Inputs, result tables and portable construction records | `experiments/` | None to inspect; Python to verify |
| Full statement preparation, library integration and proof execution | External construction backend | Backend installation and model service |

Importing or installing the public tools does not import a construction backend. The completed ReasLib examples compile independently. Reproducing the full construction process requires the external backend; inspecting and validating the released outputs does not.

## Installation and entry points

```bash
python3 -m pip install --no-deps .
lift-extract --help
lift-translate --help
lift-repair --help
```

The installed distribution contains `lift_tools`. Evidence commands in `lift_artifacts` run from the source checkout with its released data. The `tools/` Python entry points also work directly from a source checkout. The distribution packages the Lean compiler probe as data and has no Python runtime dependency on an external engine. The implementation uses the current project's compiler, not a bundled Lean executable.

## Model interface

Translation calls an executable selected with `--model-command`. Each invocation receives one JSON request on stdin and emits `{ "response": {...}, "model": "...", "usage": { "total_tokens": 123 } }` on stdout. Unknown usage is `null`. Translation and review are separate invocations; the executable can route them to different models using the `role` field. Each recorded review binds the exact draft and compiler context. A provider failure is recorded and stops that run; no hidden transport retries occur.

The supplied `tools/lean_json/model.py` adapter supports HTTPS Chat Completions and Responses endpoints with runtime variables `LIFT_MODEL_ENDPOINT`, `LIFT_MODEL`, and `LIFT_MODEL_API_KEY`. Set `LIFT_MODEL_API_STYLE=responses` for a `/responses` endpoint; the default is `chat_completions`. Responses calls disable storage and do not set a reasoning-effort override. `LIFT_MODEL_STREAM=1` requests Responses SSE and requires a complete terminal event; partial deltas are never accepted. `LIFT_MODEL_TIMEOUT_SECONDS` controls the HTTP read timeout (default 240 seconds); set the outer tool `--timeout` or `--model-timeout` higher to include provider execution and admission waiting. Configure credentials in the calling environment. They do not belong in arguments, prompts or result files. The adapter follows the [JSON response contract](https://docs.x.ai/developers/model-capabilities/text/structured-outputs); endpoints must support `response_format: json_object` and report completion status.

## Construction boundary

M2F source, internal prompts, native job directories, credentials and raw provider logs are not distributed here. Backend-specific orchestration remains in a separate private installation. Portable results consist of selected mathematical sources, declaration facts, source recoveries, immutable client checks and explicit usage summaries. They do not require publishing the engine implementation.

Public tests import the tools in isolated Python and check that the public package has no private-engine imports. Publication checks bind the reviewed release files by digest. Local executions write to `_runs/`, which is excluded from publication.
