# github-runner

Thin wrapper over `myoung34/github-runner:ubuntu-jammy` for the Railway self-hosted runner.

Adds a job-started hook (`ACTIONS_RUNNER_HOOK_JOB_STARTED=/opt/runner-hooks/job-started.sh`)
that deletes old job folders under `/_work` (keeping the current job's workspace and the runner's
`_actions`/`_tool` dirs) and empties `_temp`, so the container stays under Railway's
ephemeral storage limit. Logs one `[runner-cleanup]` line per job. Base entrypoint unchanged.
All runner config stays in Railway env vars.
