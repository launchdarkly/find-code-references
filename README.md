# LaunchDarkly Code References with GitHub Actions

This GitHub Action is a utility that automatically populates code references in LaunchDarkly. This is useful for finding references to feature flags in your code, both for reference and for code cleanup.

To find code references in pull requests, use [launchdarkly/find-code-references-in-pull-request](https://github.com/launchdarkly/find-code-references-in-pull-request) instead.

## Configuration

Once you've [created a LaunchDarkly access token](https://docs.launchdarkly.com/home/code/github-actions#prerequisites), store the newly created access token as a repository secret titled `LD_ACCESS_TOKEN`. Under Settings > Secrets in your GitHub repo, you'll see a link to "Add a new secret".  Click that and paste in your access token and click "Save secret".

(For help storing this see the [GitHub docs](https://help.github.com/en/articles/creating-a-github-action).)

Next, create a new Actions workflow in your selected GitHub repository (e.g. `code-references.yml`) in the `.github/workflows` directory of your repository.  Under "Edit new file", paste the following code:

```yaml
on: push
name: Find LaunchDarkly flag code references
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  launchDarklyCodeReferences:
    name: LaunchDarkly Code References
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 11 # This value must be set if the lookback configuration option is not disabled for find-code-references. Read more: https://github.com/launchdarkly/ld-find-code-refs#searching-for-unused-flags-extinctions
    - name: LaunchDarkly Code References
      uses: launchdarkly/find-code-references@v2.13.0
      with:
        accessToken: ${{ secrets.LD_ACCESS_TOKEN }}
        projKey: LD_PROJECT_KEY
```

We strongly recommend that you update the second `uses` attribute value to reference the latest tag in the [launchdarkly/find-code-references repository](https://github.com/launchdarkly/find-code-references). This will pin your workflow to a particular version of the `launchdarkly/find-code-references` action. Also, make sure to change `projKey` to the key of the LaunchDarkly project associated with this repository.

Commit this file under a new branch. Submit as a PR to your code reviewers to be merged into your default branch. You do not need to have this new branch merged into the default branch for code references to appear in the LaunchDarkly UI for your flags. Code references appear for this new branch as soon as it is published.

As shown in the above example, the workflow should run on the `push` event, and contain an action provided by the [launchdarkly/find-code-references repository](https://github.com/launchdarkly/find-code-references). The `LD_ACCESS_TOKEN` configured in the previous step should be included as a secret, as well as a new environment variable containing your LaunchDarkly project key.

## Additional configuration

To customize additional configuration not referenced in [Inputs](#inputs), you may use a configuration file located at `.launchdarkly/coderefs.yml`. The following links provide more inforation about configurable options:

- [All configuration options](https://github.com/launchdarkly/ld-find-code-refs/blob/main/docs/CONFIGURATION.md)
- [Monorepo configuration](https://github.com/launchdarkly/ld-find-code-refs/blob/main/docs/CONFIGURATION.md#projects)
- [Alias configuration](https://github.com/launchdarkly/ld-find-code-refs/blob/main/docs/ALIASES.md).

## Additional Examples
The example below is the same as first, but it also excludes any `dependabot` branches. We suggest excluding any automatically generated branches where flags do not change.

```yaml
on:
  push:
    branches-ignore:
      - 'dependabot/**'

name: Find LaunchDarkly flag code references
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  launchDarklyCodeReferences:
    name: LaunchDarkly Code References
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 11 # This value must be set if the lookback configuration option is not disabled for find-code-references. Read more: https://github.com/launchdarkly/ld-find-code-refs#searching-for-unused-flags-extinctions
    - name: LaunchDarkly Code References
      uses: launchdarkly/find-code-references@v2.13.0
      with:
        accessToken: ${{ secrets.LD_ACCESS_TOKEN }}
        projKey: LD_PROJECT_KEY
```

## Troubleshooting

Once your workflow has been created, the best way to confirm that the workflow is executing correctly is to create a new pull request with the workflow file and verify that the newly created action succeeds.

If the action fails, there may be a problem with your configuration. To investigate, dig into the action's logs to view any error messages.

<!-- action-docs-inputs source="action.yml" -->
## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `accessToken` | <p>A token with write access to the LaunchDarkly project.</p> | `true` | `""` |
| `allowTags` | <p>Enable storing references for tags. Lists the tag as a branch.</p> | `false` | `false` |
| `baseUri` | <p>The base URL of the LaunchDarkly server for this configuration.</p> | `false` | `https://app.launchdarkly.com` |
| `contextLines` | <p>The number of context lines above and below a code reference for the job to send to LaunchDarkly. By default, the flag finder will not send any context lines to LaunchDarkly. If < 0, it will send no source code to LaunchDarkly. If 0, it will send only the lines containing flag references. If > 0, it will send that number of context lines above and below the flag reference. You may provide a maximum of 5 context lines.</p> | `false` | `2` |
| `debug` | <p>Enable verbose debug logging.</p> | `false` | `false` |
| `ignoreServiceErrors` | <p>If enabled, the scanner will terminate with exit code 0 when the LaunchDarkly API is unreachable or returns an unexpected response.</p> | `false` | `false` |
| `lookback` | <p>Set the number of commits to search in history for whether you removed a feature flag from code. You may set to 0 to disable this feature. Setting this option to a high value will increase search time.</p> | `false` | `10` |
| `projKey` | <p>Key of the LaunchDarkly project associated with this repository. Found under Account Settings -&gt; Projects in the LaunchDarkly dashboard. Cannot be combined with <code>projects</code> block in configuration file.</p> | `false` | `""` |
| `repoName` | <p>The repository name. Defaults to the current GitHub repository.</p> | `false` | `""` |
| `prune` | <p>There is a known issue where the GitHub Action will not prune deleted branch data in private repos. Only enable this if you are running the action in a public repo.</p> | `false` | `false` |
| `subdirectory` | <p>The subdirectory to run the action in.</p> | `false` | `""` |
| `defaultBranch` | <p>The default branch. The LaunchDarkly UI will default to this branch. If not provided, will fallback to 'main'.</p> | `false` | `""` |
<!-- action-docs-inputs source="action.yml" -->
