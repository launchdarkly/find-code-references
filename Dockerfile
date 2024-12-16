# FROM launchdarkly/ld-find-code-refs-github-action:2.12.0

FROM alpine:3.20.3

RUN apk update
RUN apk add --no-cache git

COPY ld-find-code-refs-github-action /ld-find-code-refs-github-action

LABEL com.github.actions.name="LaunchDarkly Code References"
LABEL com.github.actions.description="Find references to feature flags in your code."
LABEL com.github.actions.icon="toggle-right"
LABEL com.github.actions.color="gray-dark"
LABEL homepage="https://www.launchdarkly.com"

ENTRYPOINT ["/ld-find-code-refs-github-action"]
