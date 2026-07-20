# Python Ecosystem Reference (verified July 2026)

Version-sensitive facts backing SKILL.md. Current stable: **Python 3.14** (released Oct 2025; patch releases through 2026, e.g. 3.14.3 Feb 2026). 3.15 in beta (3.15.0b3 as of June 2026), lands Oct 2026. Skill stance: **3.10+ syntax floor, 3.12+ preferred for new projects, 3.13/3.14-only idioms behind a version-check note.**

## Version landscape

| Version | Date / status | Idiom-relevant facts |
|---|---|---|
| 3.9 | EOL Oct 2025 | Below the floor; `str.removeprefix/suffix` originated here |
| 3.10 | security-only, EOL Oct 2026 | Syntax floor: `X | Y` unions, `match`, parenthesized `with`, `zip(strict=True)` |
| 3.11 | supported | `Self` type; faster interpreter |
| 3.12 | supported / preferred | **PEP 695** type params (`class Box[T]`, `type` statement); `itertools.batched` |
| 3.13 | supported | New PyREPL, colored tracebacks by default, better error messages (keyword-arg/module-shadowing suggestions) — changes *debugging* idioms, not code |
| 3.14 | **current stable** (Oct 2025) | **t-strings** (PEP 750); **free-threading officially supported** (PEP 779); deferred annotations (PEP 649/749 — `from __future__ import annotations` no longer needed) |
| 3.15 | beta, lands Oct 2026 | — |

Community baseline: Scientific Python (SPEC 0) supports only the 3 most recent minors.

## Feature status notes

- **PEP 695 generics** (3.12): `class Box[T]`, `def first[T](...)`, `type Maybe[T] = T | None`. It is **grammar — typing_extensions cannot backport it**; 3.11-or-older code keeps `TypeVar`/`Generic`. Ruff auto-migrates: UP040 (TypeAlias → `type`), UP046/UP047 (Generic/TypeVar → brackets).
- **`Self`** (3.11, or typing_extensions): return from fluent/builder methods, not the concrete class name.
- **t-strings** (3.14, PEP 750): `t"...{user_id}"` yields a `Template` (static parts + values kept separate) for library APIs to escape/parameterize SQL/HTML/shell. **Library adoption still early** as of mid-2026 (sqlite3/psycopg/httpx-style APIs emerging, not widespread) — f-strings remain the application-level default; use t-strings only where an API accepts them.
- **Free-threading** (3.14, PEP 779): officially supported, no longer experimental. Single-thread overhead down to ~3–8% (was 15–20% in 3.13t). cp314t wheels exist for numpy, pydantic, most top packages, but coverage isn't universal. **Posture: test your suite on 3.14t now; don't deploy free-threaded to production yet; don't restructure code assuming the GIL is gone.** "Spawn processes for parallelism" is no longer the only answer.
- **Deferred annotations** (3.14, PEP 649/749): drop `from __future__ import annotations`; keep it in code that must run on ≤3.13.
- **PEP 671 late-bound defaults**: never landed — the `None`-sentinel remains the idiom for mutable defaults (ruff B006).

## Typing / checker landscape

- **Incumbents**: mypy and pyright. **The Rust generation arrived**: **Pyrefly (Meta)** hit stable **1.0 in May 2026** (monthly cadence, auto-converts mypy/pyright config, ~88% typing-spec conformance); **ty (Astral)** is still **beta** (10–60x faster than mypy/pyright, 1.0 targeted later 2026, lower ~53% conformance). Notable practitioners (FastAPI's author) run ty *alongside* mypy.
- **Skill guidance — do not hard-recommend one**: "pyright or mypy today, ty/pyrefly are credible and fast, pick one and run it in CI."

## Tooling landscape (current vs superseded)

| Concern | Current (2026) | Superseded / wrong for new projects |
|---|---|---|
| Package/project mgr | **uv** (Astral): `uv init/add/run/lock/sync`, `uvx`; commit `pyproject.toml` + `uv.lock` | `pip install` into hand-managed venvs, requirements.txt as source of truth, Poetry |
| Lint + format | **ruff** (800+ rules; linter *and* formatter) | flake8 + isort + black + pyupgrade + pydocstyle |
| Testing | **pytest 8.x** (`test_*` functions + fixtures) | unittest.TestCase classes in new code |

- **uv** status: de facto standard; ~75M monthly PyPI downloads (passed Poetry's ~66M); 85k+ stars; overtook pip in CI for major projects (Wagtail 66% uv). Still **0.x** (0.11.x as of June 2026, no 1.0 yet, moving fast). pip remains fine as universal fallback / in constrained environments.
- **ruff** status: 0.15 (Feb 2026) + "2026 style guide" made the formatter a full-time Black replacement; PyPI's Warehouse migrated April 2026. Config `[tool.ruff]`; enable at least `E,F,W,I,UP,B,SIM,C4`; run `ruff format`.
- **pytest** conventions: src layout, tests/ separate, config in pyproject.toml with `--strict-markers` + `--import-mode=importlib`; shared fixtures in conftest.py; `@pytest.mark.parametrize`; `pytest.raises`; pytest-mock's `mocker` over manual patching; pytest-randomly + `pytest -n auto` (xdist) to flush order/state coupling.

## Data-modeling division of labor (settled)

**Internal data → stdlib `dataclass`** (`slots=True`, `frozen=True` where sensible, `kw_only=True` for many fields, `field(default_factory=list)`). **Trust boundary (API, config, LLM/tool output) → Pydantic v2** (Rust core; validation/coercion; **2–3x overhead vs dataclass in tight loops** — not for hot-path internal objects). On FastAPI projects standardize on Pydantic rather than mixing. **attrs (+cattrs)**: power option for internal models wanting validators/slots without pydantic's runtime cost — one-line mention; the main axis is dataclass vs pydantic.

## Ruff-enforceable idiom rules (cite so fixes are mechanical)

B006 (mutable defaults), C4 (comprehensions), UP/UP040/UP046/UP047 (modern typing spellings), SIM (context managers). Most section-5 wrong/right pairs have a matching rule.

## Key sources

- docs.python.org/3/whatsnew/3.14.html and /3.13.html; peps.python.org/pep-0750 (t-strings), pep-0695, pep-0779 (free-threading), pep-0649
- typing.python.org/en/latest/reference/best_practices.html; astral.sh/blog/ty; danilchenko.dev pyrefly-vs-mypy-vs-ty
- docs.astral.sh/ruff/faq; astral.sh/blog/ruff-v0.15.0; github.com/astral-sh/uv/releases
- docs.pytest.org/en/stable/explanation/goodpractices.html; devguide.python.org/versions; endoflife.date/python
- py-free-threading.github.io/tracking; pyreadiness.org/3.14
