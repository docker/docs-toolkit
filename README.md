# Docker Docs Toolkit

Shared tooling for technical content authored by Docker.

The repository currently publishes the `Docker` package for
[Vale](https://vale.sh/). The package contains Docker's writing rules,
canonical Docker names, and canonical industry terms. Repository-specific
spelling vocabularies, parsing, generated-content exclusions, and severity
overrides belong in each consuming repository.

## Use the Vale package

Add a `.vale.ini` file to your repository and pin the package to a release:

```ini
StylesPath = .vale/styles
MinAlertLevel = suggestion
Packages = https://github.com/docker/docs-toolkit/releases/download/v0.1.0/Docker.zip

[*.md]
BasedOnStyles = Docker
```

Install the package and run Vale:

```console
vale sync
vale .
```

Repositories can disable or change the severity of individual rules in their
local configuration. For example:

```ini
[*.md]
BasedOnStyles = Docker
Docker.We = suggestion

[CHANGELOG.md]
BasedOnStyles =
```

## Develop the package

Run the package integration test:

```console
./scripts/test.sh
```

Build the release archive:

```console
./scripts/package.sh
```

The archive is written to `dist/Docker.zip`. Tags matching `v*` trigger the
release workflow, which tests the package and attaches `Docker.zip` to a
GitHub release.

## Repository layout

```text
styles/Docker/                          Vale rules
fixtures/                               Integration-test content
scripts/package.sh                      Release archive builder
scripts/test.sh                         Package installation test
```

Agent skills for reusable technical-writing workflows may be added under
`skills/`. They should remain independently installable from the Vale package.

The package does not provide a general spelling vocabulary. Canonical-name
rules enforce established names and intentional naming variants; each
repository owns spelling exceptions for its domain.

Industry-term rules target recognizable naming variants such as `Github`,
`Javascript`, and `TestContainers`. They do not flag every lowercase form,
because lowercase terms often appear legitimately in commands, image names,
paths, and identifiers.

Vale's built-in style is optional. Repositories that want its spelling and
other checks can enable it separately and maintain an appropriate local
vocabulary:

```ini
[*.md]
BasedOnStyles = Docker, Vale
```

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).
