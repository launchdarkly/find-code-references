FROM launchdarkly/ld-find-code-refs-github-action:2.5.5

LABEL com.github.actions.name="LaunchDarkly Code References"
LABEL com.github.actions.description="Find references to feature flags in your code."
LABEL com.github.actions.icon="toggle-right"
LABEL com.github.actions.color="gray-dark"
LABEL homepage="https://www.launchdarkly.com"

ENTRYPOINT ["/ld-find-code-refs-github-action"]
