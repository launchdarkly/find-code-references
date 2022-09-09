# LaunchDarkly Code References with GitHub Actions

This GitHub Action is a utility that automatically populates code references in LaunchDarkly. This is useful for finding references to feature flags in your code, both for reference and for code cleanup.

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
    - uses: actions/checkout@v3
      with:
        fetch-depth: 10 # This value must be set if the lookback configuration option is not disabled for find-code-references. Read more: https://github.com/launchdarkly/ld-find-code-refs#searching-for-unused-flags-extinctions
    - name: LaunchDarkly Code References
      uses: launchdarkly/find-code-references@v2.6.3
      with:
        accessToken: ${{ secrets.LD_ACCESS_TOKEN }}
        projKey: LD_PROJECT_KEY
```

We strongly recommend that you update the second `uses` attribute value to reference the latest tag in the [launchdarkly/find-code-references repository](https://github.com/launchdarkly/find-code-references). This will pin your workflow to a particular version of the `launchdarkly/find-code-references` action. Also, make sure to change `projKey` to the key of the LaunchDarkly project associated with this repository.

Commit this file under a new branch.  Submit as a PR to your code reviewers to be merged into your default branch.  You do not need to have this branch merged into the default branch for code references to appear in the LaunchDarkly UI for your flags; code references will appear for this newly created branch.

As shown in the above example, the workflow should run on the `push` event, and contain an action provided by the [launchdarkly/find-code-references repository](https://github.com/launchdarkly/find-code-references). The `LD_ACCESS_TOKEN` configured in the previous step should be included as a secret, as well as a new environment variable containing your LaunchDarkly project key.

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
    - uses: actions/checkout@v3
      with:
        fetch-depth: 10 # This value must be set if the lookback configuration option is not disabled for find-code-references. Read more: https://github.com/launchdarkly/ld-find-code-refs#searching-for-unused-flags-extinctions
    - name: LaunchDarkly Code References
      uses: launchdarkly/find-code-references@v2.6.3
      with:
        accessToken: ${{ secrets.LD_ACCESS_TOKEN }}
        projKey: LD_PROJECT_KEY
```
## Troubleshooting

Once your workflow has been created, the best way to confirm that the workflow is executing correctly is to create a new pull request with the workflow file and verify that the newly created action succeeds.

If the action fails, there may be a problem with your configuration. To investigate, dig into the action's logs to view any error messages.

<!-- action-docs-inputs -->
## Inputs

| parameter | description | required | default |
| - | - | - | - |
| accessToken | A token with write access to the LaunchDarkly project. | `true` |  |
| allowTags | Enable storing references for tags. Lists the tag as a branch. | `false` | false |
| baseUri | The base URL of the LaunchDarkly server for this configuration. | `false` | https://app.launchdarkly.com |
| contextLines | The number of context lines above and below a code reference for the job to send to LaunchDarkly. By default, the flag finder will not send any context lines to LaunchDarkly. If < 0, it will send no source code to LaunchDarkly. If 0, it will send only the lines containing flag references. If > 0, it will send that number of context lines above and below the flag reference. You may provide a maximum of 5 context lines. | `false` | 2 |
| debug | Enable verbose debug logging. | `false` | false |
| ignoreServiceErrors | If enabled, the scanner will terminate with exit code 0 when the LaunchDarkly API is unreachable or returns an unexpected response. | `false` | false |
| lookback | Set the number of commits to search in history for whether you removed a feature flag from code. You may set to 0 to disable this feature. Setting this option to a high value will increase search time. | `false` | 10 |
| projKey | Key of the LaunchDarkly project associated with this repository. Found under Account Settings -> Projects in the LaunchDarkly dashboard. Cannot be combined with `projects` block in configuration file. | `false` |  |
| repoName | The repository name. Defaults to the current GitHub repository. | `false` |  |



<!-- action-docs-inputs -->
