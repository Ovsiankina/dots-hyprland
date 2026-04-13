# Syncing with Upstream

This is a heavily modified fork. Syncing from upstream is selective—only integrate changes that fit our use case.

## Workflow

1. Create a test branch from upstream:
```bash
git checkout upstream
git pull origin upstream
git checkout -b test/sync
```

2. Merge `main` to preview conflicts:
```bash
git merge main
```

3. Review what changed. Divergence is expected since we modify the project heavily. Resolve conflicts selectively—only keep upstream changes that matter to us.

4. If the merge looks good, apply to main:
```bash
git checkout main
git merge test/sync
git branch -d test/sync
```

If conflicts are problematic, discard the test branch and try a different approach:
```bash
git branch -D test/sync
```

## Why this approach

Testing on a separate branch lets us see conflicts before they hit main. We can always discard and retry if needed.
