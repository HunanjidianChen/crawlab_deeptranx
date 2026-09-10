# Upgrade Procedure

Crawlab, crawlab-ui and MongoDB are an intentionally coupled compatibility
set. MongoDB `4.2` remains internal and pinned for the `0.6.3` baseline.

For an upgrade:

1. Create a branch and update `UPSTREAM.md` with candidate tags, commits and
   image digests.
2. Review upstream release notes, API changes and data migration requirements.
3. Rebase the minimal UI patch against the exact crawlab-ui package.
4. Update exact dependencies and regenerate the lockfile with the approved
   pnpm version.
5. Build with `--frozen-lockfile`; do not silently accept lockfile drift.
6. Back up production data and restore it into a disposable environment.
7. Test login, permissions, node health, spider upload, task execution, logs,
   results, schedules and container recreation.
8. Build the same commit twice and compare dependency resolution and base
   image references.
9. Promote the new image only after rollback to the previous image and backup
   has also been tested.

If backend behavior is changed in the future, pin the matching Crawlab backend
and submodule commits and add a Go build stage. That is intentionally outside
the current frontend-only baseline.
