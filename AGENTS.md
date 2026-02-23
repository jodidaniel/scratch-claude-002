# Common Preferences

## Red/Green TDD

When writing or modifying code that has associated tests (or should have them), follow the red/green TDD cycle:

1. **Red** -- Write a failing test that captures the expected behavior before writing or changing implementation code.
2. **Green** -- Write the minimum implementation needed to make the test pass.
3. **Refactor** -- Clean up the code while keeping tests green.

Apply this when the task involves bug fixes, new features, or behavioral changes where automated tests are practical. Skip it for purely structural changes (renames, formatting, config tweaks) where a test-first approach adds no value.
