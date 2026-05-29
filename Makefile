.PHONY: sync build publish publish-test clean

sync:
	uv sync

build:
	uv build

# Publishes to TestPyPI. Requires a TestPyPI API token.
# uv will prompt for username (__token__) and password (the token) interactively.
publish-test: build
	uv publish --publish-url https://test.pypi.org/legacy/

publish: publish-test

clean:
	rm -rf dist/ .venv/
