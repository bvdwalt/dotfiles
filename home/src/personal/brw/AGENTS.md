# brw

A Go package client compatible with Homebrew. It shares a prefix with brew, so anything it writes must be something brew accepts.

- Changes to a Homebrew prefix go through `internal/fsx`. A test fails the build on direct `os` writes elsewhere. Mark writes outside the prefix, such as the cache or journal, with `//fsx:allow <reason>`.
- Tests use temp prefixes, never `/opt/homebrew`.
- Receipts must match brew's format exactly, and `homebrew_version` must look like a real Homebrew version.
- Where brw differs from brew, keep one line naming the difference ("unlike brew, ...").
