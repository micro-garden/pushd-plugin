# pushd Plugin

**pushed** is a plugin that provides shell-like `pushd`, `popd`, and `dirs`
commands.

## Features

- Push and pop current working directory in a stack
- Switch between directories with `dirs <dir>` command
- Tab completion support using the directory stack

## Commands

- `pushd [dir]` — Push current dir and change to `dir`
- `popd` — Pop back to previous dir
- `dirs` — List current and stacked dirs
- `dirs <dir>` — Jump to dir in stack (removing it from stack and push current
  dir)
