---
name: python-idioms
description: Use when writing or reviewing Python code — new modules, refactors, code review, or porting from another language — especially when choosing data-modeling, typing, error-handling, or project-tooling approaches, or when code shows os.path, % formatting, unittest classes, getters/setters, or pre-3.10 typing spellings.
---

# Python Idioms (2026)

## Overview

Make Python code Pythonic by 2026 standards: 3.10+ syntax floor, 3.12+ preferred for new projects, uv + ruff + pytest as settled tooling. Encode judgment — which construct fits — not syntax tutorials.

## Core idioms

### EAFP over LBYL

```python
# WRONG: racy, two lookups
if key in d:
    v = d[key]
else:
    v = default

# RIGHT
v = d.get(key, default)
# For operations: try/except KeyError — ask forgiveness, not permission
```

EAFP when the exception is exceptional; `.get()`/defaults when the default is the normal path. LBYL is fine when the check is cheap, race-free, and clearer (`if not items: return`).

### pathlib over os.path

```python
# WRONG
import os
p = os.path.join(base, "data", name + ".json")
if os.path.exists(p):
    with open(p) as f: text = f.read()

# RIGHT
from pathlib import Path
p = Path(base) / "data" / f"{name}.json"
if p.exists():
    text = p.read_text(encoding="utf-8")
```

Also: `Path.glob`, `p.mkdir(parents=True, exist_ok=True)`, `p.suffix`, `p.stem`. Always pass `encoding=` for text I/O.

### Comprehensions — use, but know the limit (ruff C4)

```python
# WRONG: accumulator loop for a simple transform
out = []
for x in xs:
    if x > 0:
        out.append(x * 2)

# RIGHT
out = [x * 2 for x in xs if x > 0]

# WRONG: unreadable nesting — go back to a loop or extract a generator function
result = [f(x, y) for x in xs if p(x) for y in ys if q(x, y) if r(y)]
```

One `for`, at most one `if`; no side effects inside. Generator expression when iterating once: `sum(x*x for x in xs)`. Dict/set comprehensions equally idiomatic.

### Context managers for every resource (ruff SIM)

```python
# WRONG: close() skipped on exception
f = open(path)
data = f.read()
f.close()

# RIGHT
with open(path, encoding="utf-8") as f:
    data = f.read()

# RIGHT (3.10+): parenthesized multi-with
with (open(a) as fa, open(b) as fb):
    ...
```

`contextlib.contextmanager` for ad-hoc managers; `contextlib.suppress(FileNotFoundError)` over try/except/pass.

### f-strings (ruff UP)

```python
# WRONG
"Hello, %s. You are %d." % (name, age)
"Hello, {}.".format(name)

# RIGHT
f"Hello, {name}. You are {age}."
f"{value=}"          # debug form
f"{amount:,.2f}"     # format specs
```

Never interpolate untrusted data into SQL/shell via f-strings — parameterize, or use a t-string-aware API (3.14+, see below).

### Modern typing syntax (ruff UP, UP040, UP046/UP047)

```python
# WRONG: pre-3.10 spellings
from typing import Optional, Union, List, Dict
def f(x: Optional[int], y: Union[str, bytes]) -> List[Dict[str, int]]: ...

# RIGHT (3.10+): builtin generics, | unions, None last
def f(x: int | None, y: str | bytes) -> list[dict[str, int]]: ...

# WRONG: pre-3.12 generics
from typing import TypeVar, Generic
T = TypeVar("T")
class Box(Generic[T]): ...

# RIGHT (3.12+, PEP 695): scoped params, inferred variance, no imports
class Box[T]: ...
def first[T](xs: list[T]) -> T: ...
type Maybe[T] = T | None      # `type` statement replaces TypeAlias
```

PEP 695 is grammar — typing_extensions cannot backport it; 3.11-or-older code keeps TypeVar. Return `Self` (3.11+) from fluent/builder methods, not the concrete class name. Use `Protocol` for duck typing instead of ABC inheritance.

### dataclass vs pydantic vs attrs

```python
# WRONG: pydantic for a purely internal value object
class Point(BaseModel):
    x: float; y: float

# RIGHT: stdlib dataclass for internal data
@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float

# RIGHT: pydantic where untrusted data enters
class CreateUserRequest(BaseModel):
    email: EmailStr
    age: int = Field(ge=0)
```

Rule: **internal → dataclass, trust boundary (API, config, LLM output) → Pydantic v2.** Pydantic has 2–3x overhead vs dataclass in tight loops. On FastAPI projects standardize on Pydantic rather than mixing. attrs (+cattrs): power option for internal models needing validators/slots without pydantic's runtime cost. Dataclass defaults: `slots=True`, `frozen=True` where sensible, `kw_only=True` for many fields.

### Mutable default arguments (ruff B006)

```python
# WRONG: shared across all calls
def append_to(item, items=[]):
    items.append(item)
    return items

# RIGHT: None sentinel
def append_to(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items

# RIGHT in dataclasses
items: list[int] = field(default_factory=list)
```

### match — for structure, not values

```python
# WRONG: match as a switch on flat values — use if/elif or dict dispatch
match status:
    case 200: ...
    case 404: ...

# RIGHT: destructuring variant-shaped data (ASTs, events, JSON commands)
match event:
    case {"type": "click", "pos": (x, y)}:
        handle_click(x, y)
    case Point(x=0, y=0):
        origin()
    case _:
        raise ValueError(f"unknown event: {event!r}")
```

Reach for `match` when you'd otherwise write isinstance-checks plus unpacking. **Gotcha:** a bare name in a case pattern is a capture, not a constant — `case RED:` matches everything; use dotted names (`case Color.RED:`).

### Staples — one line each

- `enumerate(xs)` and `zip(a, b, strict=True)` (3.10+) over index arithmetic.
- `first, *rest = xs`; swap via `a, b = b, a`.
- `is None` / `is not None`, never `== None`; truthiness for emptiness (`if not xs:`).
- Generators over intermediate lists; `yield from` for delegation.
- `raise ... from e` to preserve cause; catch narrow types, never bare `except:`.
- `logger = logging.getLogger(__name__)` over print in libraries.
- `if __name__ == "__main__":` calling a `main()` function.
- `functools.cache` / `cached_property`; `itertools.batched` (3.12+) over hand-rolled chunking.
- `str.removeprefix`/`removesuffix` over slicing arithmetic.
- `datetime.now(tz=timezone.utc)` / `zoneinfo` — never naive datetimes or pytz.

## Anti-patterns (Java-in-Python)

| Anti-pattern | Pythonic replacement |
|---|---|
| `get_x()`/`set_x()` methods | Plain attribute; `@property` only when access needs logic |
| Class with only `__init__` + one method | A function |
| Class as namespace for static methods | Module-level functions |
| ABC inheritance to type a duck | `Protocol` (structural typing) |
| Builder returning `-> "Query"` | `-> Self` (3.11+) |
| `dict[str, Any]` for known shapes | TypedDict (dict-shaped JSON/kwargs) or dataclass (behavior-bearing object) |
| unittest.TestCase classes in new code | Plain pytest `test_*` functions + fixtures |

## Typing policy

- Annotate all public function signatures; untyped new code reads as legacy. Don't annotate obvious locals.
- Arguments wide, returns narrow: accept `Iterable`/`Mapping`/`Sequence`, return `list`/`dict` concretely.
- Checker: pyright or mypy today; ty and Pyrefly are credible and fast — pick one and run it in CI. Don't hard-recommend a single winner (see references/ecosystem.md).

## Tooling defaults

- **uv** for everything: `uv init`, `uv add`, `uv run`, `uv lock`/`uv sync`, `uvx` for tools; commit `pyproject.toml` + `uv.lock`. Wrong: `pip install` into hand-managed venvs, requirements.txt as source of truth, Poetry for new projects. pip stays as universal fallback in constrained environments.
- **ruff** as linter *and* formatter (replaces flake8+isort+black+pyupgrade). Config under `[tool.ruff]` in pyproject.toml; enable at least `E,F,W,I,UP,B,SIM,C4`; run `ruff format`.
- **pytest**: src layout, tests/ separate, config in pyproject.toml with `--strict-markers` and `--import-mode=importlib`; shared fixtures in conftest.py; `@pytest.mark.parametrize` over copy-pasted tests; `pytest.raises` for exceptions; pytest-mock's `mocker` over manual patching; pytest-randomly + `pytest -n auto` to flush order/state coupling.

```python
# WRONG: unittest style, repeated tests
class TestAdd(unittest.TestCase):
    def test_one(self): self.assertEqual(add(1, 1), 2)

# RIGHT: pytest + parametrize
@pytest.mark.parametrize(("a", "b", "want"), [(1, 1, 2), (2, 2, 4)])
def test_add(a, b, want):
    assert add(a, b) == want
```

## What's new enough to flag

- **t-strings (3.14+, PEP 750):** `t"... {user_id}"` yields a `Template` (static parts and values kept separate) for library APIs to escape/parameterize SQL, HTML, shell safely. Library adoption still early — f-strings remain the application-level default; use t-strings when an API accepts them.
- **Free-threading (3.14, PEP 779):** officially supported, not yet the deployment norm. Test your suite on 3.14t now; don't deploy free-threaded to production yet and don't restructure code for it. "Spawn processes for parallelism" is no longer the only answer, but don't write code assuming the GIL is gone.
- **3.14+:** `from __future__ import annotations` no longer needed (PEP 649/749). Keep it in code that must run on ≤3.13.
- **3.13+ debugging:** read the improved traceback (colored, keyword-arg suggestions, module-shadowing detection) before reaching for print().

Version-sensitive facts — release status, tool versions, wheel coverage, checker landscape: see [references/ecosystem.md](references/ecosystem.md).
