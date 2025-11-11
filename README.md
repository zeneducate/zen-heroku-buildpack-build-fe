This buildpack builds the Zen Educate FE app.

## Requirements

- Node.js (provided by another buildpack)
- pnpm (should be available in the build environment)
- A `web` directory in your application root
- A `pnpm-lock.yaml` file in the `web` directory
- A `web/bin/sha-files` script for calculating checksums

## How It Works

This buildpack:

1. **Calculates a checksum** of your web directory to determine if a build is needed
2. **Checks the cache** for a previously built version with the same checksum
3. **Restores cached dependencies** if `pnpm-lock.yaml` hasn't changed
4. **Installs dependencies** with `pnpm install --frozen-lockfile` if not cached
5. **Builds the frontend** using `pnpm run build` with WEB_* environment variables
6. **Caches the build** for future deployments
7. **Cleans up** the slug to keep it small (keeps only `dist`, `bin`, and `public`)

## Environment Variables

Environment variables prefixed with `WEB_` are automatically passed to the build process with the prefix removed. For example:

- `WEB_API_URL` becomes `API_URL` in the build environment
- `WEB_NODE_ENV` becomes `NODE_ENV` in the build environment

## Caching

The buildpack caches two things:

1. **node_modules** - Cached by `pnpm-lock.yaml` checksum at `$CACHE_DIR/pnpm-cache/<checksum>/`
2. **Built dist** - Cached by web directory checksum at `$CACHE_DIR/web-builds/<checksum>/`

## Testing

Use the included test script to test the buildpack locally:

```bash
./test-buildpack.sh /path/to/your/app
```

The test script simulates the Heroku build environment and runs the buildpack with proper directories.

## Special Behavior

- Skips build for review apps (except `zeneducate-pr-224`)
- Sets `NODE_OPTIONS='--max-old-space-size=4096'` for memory-intensive builds
- Exits gracefully if no `web` directory is found
