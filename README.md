# honcho-docker

Build and publish `plastic-labs/honcho` container images to `ghcr.io/matrixhawk/honcho`.

## How it works

- A scheduled GitHub Actions workflow checks the newest upstream tag from [`plastic-labs/honcho`](https://github.com/plastic-labs/honcho).
- If `ghcr.io/matrixhawk/honcho:<tag>` already exists, the workflow exits without rebuilding.
- If the image tag does not exist, the workflow builds directly from the upstream Git tag and reuses upstream's `Dockerfile`.
- When the built tag is also the highest stable upstream version (`vMAJOR.MINOR.PATCH`), the workflow also publishes `ghcr.io/matrixhawk/honcho:latest`.

## Manual rebuild

Use `Actions -> Publish Honcho Image -> Run workflow`.

- Leave `tag` empty to build the latest upstream tag.
- Set `tag` to an explicit upstream tag such as `v3.0.6` to rebuild that version.
- Set `force` to `true` to rebuild even if the image tag already exists in GHCR.

## Permissions

The workflow uses the repository `GITHUB_TOKEN` and requires:

- `contents: read`
- `packages: write`

No extra secrets are required for publishing to `ghcr.io/matrixhawk/honcho` from this repository under the same GitHub owner.

## Upstream assumptions

- Upstream tags are published on [`plastic-labs/honcho`](https://github.com/plastic-labs/honcho/tags).
- Upstream currently does not publish GitHub Releases.
- Upstream `Dockerfile` remains buildable from a remote Git context.
