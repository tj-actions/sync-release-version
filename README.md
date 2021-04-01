[![CI](https://github.com/tj-actions/sync-release-version/workflows/CI/badge.svg)](https://github.com/tj-actions/sync-release-version/actions?query=workflow%3ACI)
[![Update release version.](https://github.com/tj-actions/sync-release-version/workflows/Update%20release%20version./badge.svg)](https://github.com/tj-actions/sync-release-version/actions?query=workflow%3A%22Update+release+version.%22)

sync-release-version
--------------------
Problem
-------
With multiple files that need to be updated each time a new version of your software is released.


`sync-release-version` makes this process less complex by using [sed's](https://www.gnu.org/software/sed/manual/sed.html) regex pattern to match the sections in the specified files that needs to be updated.

Helpful Resources
------------------
- https://www.regextester.com/111539
- https://www.tutorialspoint.com/unix/unix-regular-expressions.htm

Usage
-----

#### Sync a project release version number.

Update files that reference a project version with a new release number.

> NOTE: This example assumes a post release operation i.e changes are made to a README after a new version is releaased.

```yaml
...
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0 # otherwise, you will failed to push refs to dest repo
      - name: Sync release version.
        uses: tj-actions/sync-release-version@v8.4
          id: sync-release-version
          with:
            current_version: '1.0.1'  # Omit to use git tag.
            new_version: '1.0.2'  # Omit when running on a release action.
            paths: |
              README.md
              test/subdir/README.md
      - run: |
        echo "Upgraded from ${{ steps.sync-release-version.outputs.old_version }} -> ${{ steps.sync-release-version.outputs.new_version }}" 
```


### Recomended usage with [peter-evans/create-pull-request@v3](https://github.com/peter-evans/create-pull-request)

```yaml
name: Update release version.
on:
  release:
    types: [published]


jobs:
  update-version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Sync release version.
        uses: tj-actions/sync-release-version@v8.4
        id: sync-release-version
        with:
          pattern: 'tj-actions/sync-release-version@'
          paths: |
            README.md
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v3
        with:
          base: "master"
          title: "Upgraded to ${{ steps.sync-release-version.outputs.new_version }}"
          branch: "upgrade-to-${{ steps.sync-release-version.outputs.new_version }}"
          commit-message: "Upgraded from ${{ steps.sync-release-version.outputs.old_version }} -> ${{ steps.sync-release-version.outputs.new_version }}"
          body: "View [CHANGES](https://github.com/${{ github.repository }}/compare/${{ steps.sync-release-version.outputs.old_version }}...${{ steps.sync-release-version.outputs.new_version }})"
          reviewers: "jackton1"
```

Example
-------

![Sample](./Sample.png)

Creating a new release `v6.8 -> v7` using the recommended configuration above.

#### BEFORE

`README.md`
```yaml
...
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Sync release version.
        uses: tj-actions/sync-release-version@v6.8
```

#### AFTER
`README.md`
```yaml
...
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Sync release version.
        uses: tj-actions/sync-release-version@v7
```


Inputs
------

|   Input           |    type       |  required     |  default                | description                                                     |
|:-----------------:|:-------------:|:-------------:|:-----------------------:|:---------------------------------------------------------------:|
| `token`           |  `string`     |    `true`     | `${{ github.token }}`   | [GITHUB_TOKEN](https://docs.github.com/en/free-pro-team@latest/actions/reference/authentication-in-a-workflow#using-the-github_token-in-a-workflow) <br /> or a repo scoped <br /> [Personal Access Token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)                            |
| `current_version` |  `string`     |    `false`    |                         | The current project version <br /> (Defualts to: The last git tag)     |
| `new_version`     |  `string`     |    `false`    |                         | The next project version <br /> (Defaults to: The new git tag)         |
| `paths`           |  `array`      |    `true`     |                         | A list of file names to search <br /> and replace versions.            |
| `pattern`         |  `string`     |    `false`    |    `''`                 | The pattern to match the location <br /> that needs to be updated      |



Output
------

|   Output         |    type     |  example              | description                   |
|:----------------:|:-----------:|:---------------------:|:-----------------------------:|
| `new_version`    |  `string`   |    `1.2.1`            |  The current project version |
| `old_version`    |  `string`   |    `1.2.0`            |  The previous project version |



* Free software: [MIT license](LICENSE)

Features
--------

* Modifies files with an up to date version of your project based on each release tag.


Known Issues
------------
> To ignore certain lines from getting updated ensure the version used doesn't match either the current or previous version.


Credits
-------

This package was created with [Cookiecutter](https://github.com/cookiecutter/cookiecutter).



Report Bugs
-----------

Report bugs at https://github.com/tj-actions/sync-release-version/issues.

If you are reporting a bug, please include:

* Your operating system name and version.
* Any details about your workflow that might be helpful in troubleshooting.
* Detailed steps to reproduce the bug.
