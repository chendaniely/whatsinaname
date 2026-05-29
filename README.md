# what's in a name?

In Python packaging, the name you use to install a package,
the name you use to import it,
and the names of the files and functions inside it
are all separate things.
You pick each one independently.

The naming starts before you even open a file.
This repo itself is an example:

| Location | Name | How you use it |
|---|---|---|
| GitHub repo folder | `whatsinaname` | `git clone .../whatsinaname` |
| PyPI / install name | `whats-in-a-name` | `pip install whats-in-a-name` |
| Python import name | `whatsinaname`, `whats_in_a_name`, ... | `import whatsinaname` |
| Module / function | `whatsinaname.py`, `greet()`, ... | `from pkg.mod import fn` |

Tutorials tend to name all of these the same thing,
which makes it hard to tell which piece of an import statement refers to which thing.
Each example here changes just one name at a time.

> **Note on package structure:**
> A real package would have one folder under `src/`.
> This repo has six, one per teaching example.
> That means `pip install whats-in-a-name` installs all six at once,
> because every folder listed under `[tool.hatch.build.targets.wheel] packages`
> in `pyproject.toml` gets bundled into the same wheel.
> You end up with six importable namespaces (`whatsinaname`, `whats_in_a_name`, etc.) from a single install.
> That is not typical, but it is intentional here so you can try all the examples without installing anything extra.
> Some real packages do ship multiple importable namespaces from one install:
> `pip install attrs` gives you both `import attr` and `import attrs`;
> `pip install setuptools` gives you both `import setuptools` and `import pkg_resources`.

## Multiple `src/` folders vs separate dependencies

Bundling multiple folders under `src/` is different from listing packages as dependencies.

**Multiple `src/` folders** means everything ships in one wheel with one version number.
All six example packages in this repo always move together --
you cannot install one without the others,
and a fix in any one of them means re-releasing the whole `whats-in-a-name` distribution.

**Separate dependencies** are independent packages listed under `[project.dependencies]` in `pyproject.toml`.
Each has its own wheel, its own version, and its own release cycle.
`pip` fetches and resolves them individually.
A fix in one does not require a new release of the others,
and they can be maintained by different people entirely.

`requests` is a good example of the dependency approach --
it pulls in `urllib3`, `certifi`, and others as separate packages, each with independent versions.
`attrs` is an example of the bundled approach --
`attr` and `attrs` are always the same version because they come from the same project.

For most packages, one folder under `src/` and no bundling is the right call.

## Getting started

Clone the repo and run `uv sync` to create a virtual environment and install all six example packages at once:

```bash
git clone https://github.com/chendaniely/whatsinaname
cd whatsinaname
uv sync
```

`uv sync` creates `.venv/` and installs `whats-in-a-name` (along with all bundled packages) into it.
From there you can either activate the environment or use `uv run` to run things inside it:

```bash
# activate and use directly
source .venv/bin/activate
python

# or run a single command without activating
uv run python
```

Once inside Python, all six packages are importable:

```python
from whatsinaname.whatsinaname import whatsinaname
from whats_in_a_name.whatsinaname import whatsinaname
from whats_new_module.greetings import whatsinaname
from whats_new_func.greetings import greet
from whats_init_import import greet
from whats_init_all import greet
```

If you want to install from TestPyPI instead of cloning:

```bash
pip install --index-url https://test.pypi.org/simple/ whats-in-a-name
# or
uv add --index-url https://test.pypi.org/simple/ whats-in-a-name
```

## Publishing to TestPyPI

`uv build` and `pip install` are both build frontends.
They read `[build-system]` in `pyproject.toml` and call hatchling (the backend) to do the actual packaging.
Using `uv build` here is not in conflict with hatchling -- uv just calls hatchling under the hood.


1. Create an account at [test.pypi.org](https://test.pypi.org)
2. Go to Account Settings and create an API token
3. Export the token in your shell:
   ```bash
   export UV_PUBLISH_TOKEN=pypi-...
   ```
4. Build and publish:
   ```bash
   make publish-test
   ```
   Or without `make`:
   ```bash
   uv build
   uv publish --publish-url https://test.pypi.org/legacy/
   ```

The built wheel and source distribution will appear in `dist/`.
Each time you publish you need to bump the `version` in `pyproject.toml`,
since TestPyPI (like PyPI) does not allow re-uploading the same version.

## Examples

### Example 1: everything has the same name (`src/whatsinaname/`)

Folder, file, and function are all called `whatsinaname`.
This is typical of tutorials.

```
src/whatsinaname/
├── __init__.py         # empty for now
└── whatsinaname.py     # def whatsinaname(name)
```

```python
from whatsinaname.whatsinaname import whatsinaname
#    ^^^^^^^^^^^^  ^^^^^^^^^^^^         ^^^^^^^^^^^^
#    folder        file                 function
```

The same word appears three times.
It works, but there is no way to tell from the import
which part is the folder, which is the file, and which is the function.

---

### Example 2: folder name changes (`src/whats_in_a_name/`)

Only the folder name changes.
The file and function are still `whatsinaname`.

This is the conventional mapping:
PyPI install names use hyphens, Python import names use underscores.

```
src/whats_in_a_name/
├── __init__.py         # empty for now
└── whatsinaname.py     # def whatsinaname(name)
```

```python
# Install:  pip install whats-in-a-name   (hyphens, from pyproject.toml)
# Import:   import whats_in_a_name        (underscores, from the folder name)

from whats_in_a_name.whatsinaname import whatsinaname
#    ^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^         ^^^^^^^^^^^^
#    folder (changed!) file                 function
```

---

### Example 3: module (file) name changes (`src/whats_new_module/`)

Only the file name changes to `greetings.py`.
The function is still `whatsinaname`.

```
src/whats_new_module/
├── __init__.py         # empty for now
└── greetings.py        # def whatsinaname(name)
```

```python
from whats_new_module.greetings import whatsinaname
#                     ^^^^^^^^^         ^^^^^^^^^^^^
#                     file (changed!)   function
```

---

### Example 4: function name changes (`src/whats_new_func/`)

Only the function name changes to `greet`.
The file is still `greetings.py`.

```
src/whats_new_func/
├── __init__.py         # empty for now
└── greetings.py        # def greet(name)
```

```python
from whats_new_func.greetings import greet
#                                    ^^^^^
#                                    function (changed!)
```

---

### Example 5: `__init__.py` re-exports (`src/whats_init_import/`)

When `__init__.py` re-exports a name from a module,
callers can import from the package directly
without knowing which file the function lives in.

```
src/whats_init_import/
├── __init__.py         # from whats_init_import.greetings import greet
└── greetings.py        # def greet(name)
```

```python
# Going through the file (always works):
from whats_init_import.greetings import greet

# Going through the package (works because __init__.py re-exports it):
from whats_init_import import greet
```

Both imports work.
With the re-export in place,
you can move or rename `greetings.py` later
without changing the import that callers use.

---

### Example 6: `__all__` controls what `import *` pulls in (`src/whats_init_all/`)

`__all__` is a list of names that `from pkg import *` will import.
It does not block direct imports.

```
src/whats_init_all/
├── __init__.py         # imports greet and farewell, but __all__ = ["greet"]
└── greetings.py        # def greet(name) and def farewell(name)
```

```python
# Direct imports work regardless of __all__:
from whats_init_all import greet      # works
from whats_init_all import farewell   # also works

# Star import only brings in what __all__ lists:
from whats_init_all import *
# greet is available, farewell is not
```

---

## What changed across examples

| Example | Folder | File | Function | `__init__.py` | What it shows |
|---|---|---|---|---|---|
| 1 `whatsinaname` | `whatsinaname` | `whatsinaname.py` | `whatsinaname()` | empty | all the same name |
| 2 `whats_in_a_name` | `whats_in_a_name` | `whatsinaname.py` | `whatsinaname()` | empty | folder name is independent |
| 3 `whats_new_module` | `whats_new_module` | `greetings.py` | `whatsinaname()` | empty | file name is independent |
| 4 `whats_new_func` | `whats_new_func` | `greetings.py` | `greet()` | empty | function name is independent |
| 5 `whats_init_import` | `whats_init_import` | `greetings.py` | `greet()` | re-exports `greet` | `__init__.py` re-exports |
| 6 `whats_init_all` | `whats_init_all` | `greetings.py` | `greet()`, `farewell()` | re-exports + `__all__` | `__all__` limits `import *` |

## The `whats-in-a-*` series

Each repo in this series covers one packaging topic in isolation.

| Repo | Covers |
|---|---|
| **whats-in-a-name** (this repo) | Install names, import names, module names, function names |
| whats-in-a-entry-point | `[project.scripts]`, CLI command names |
| whats-in-a-version | `__version__`, `importlib.metadata` |
| whats-in-a-type | Type hints, `py.typed`, type stubs |
| whats-in-a-dependency | Required and optional dependencies, extras |

## How this repo was built

1. `uv init --lib` creates the `src/` layout, `pyproject.toml`, and `.python-version`
2. Change `[project] name` in `pyproject.toml` to `whats-in-a-name`
3. Switch the build backend to `hatchling` so multiple packages under `src/` can be declared:
   ```toml
   [build-system]
   requires = ["hatchling"]
   build-backend = "hatchling.build"

   [tool.hatch.build.targets.wheel]
   packages = [
       "src/whatsinaname",
       "src/whats_in_a_name",
       "src/whats_new_module",
       "src/whats_new_func",
       "src/whats_init_import",
       "src/whats_init_all",
   ]
   ```
4. Add each example package under `src/` with one change from the previous
5. `uv sync` creates `.venv` and installs the package
