FROM myoung34/github-runner:ubuntu-jammy
COPY job-started.sh /opt/runner-hooks/job-started.sh
RUN chmod 0755 /opt/runner-hooks/job-started.sh
ENV ACTIONS_RUNNER_HOOK_JOB_STARTED=/opt/runner-hooks/job-started.sh
# Base ENTRYPOINT/CMD are inherited unchanged.
