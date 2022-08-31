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
      uses: launchdarkly/find-code-references@v2.6.0
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
      uses: launchdarkly/find-code-references@v2.6.0
      with:
        accessToken: ${{ secrets.LD_ACCESS_TOKEN }}
        projKey: LD_PROJECT_KEY
```
## Troubleshooting

Once your workflow has been created, the best way to confirm that the workflow is executing correctly is to create a new pull request with the workflow file and verify that the newly created action succeeds.

If the action fails, there may be a problem with your configuration. To investigate, dig into the action's logs to view any error messages.

## Additional Options

Additional configuration options can be found at the bottom of the [LaunchDarkly GitHub Action documentation](https://docs.launchdarkly.com/home/code/github-actions#additional-configuration-options).

For information about the underlying LaunchDarkly Code References command-line tool, take a look at [this repository](https://github.com/launchdarkly/ld-find-code-refs).
