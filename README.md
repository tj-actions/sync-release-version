[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2eab60dfff084efbabaf37708fba4d66)](https://app.codacy.com/gh/tj-actions/sync-release-version?utm_source=github.com\&utm_medium=referral\&utm_content=tj-actions/sync-release-version\&utm_campaign=Badge_Grade_Settings)
[![CI](https://github.com/tj-actions/sync-release-version/workflows/CI/badge.svg)](https://github.com/tj-actions/sync-release-version/actions?query=workflow%3ACI)
[![Update release version.](https://github.com/tj-actions/sync-release-version/workflows/Update%20release%20version./badge.svg)](https://github.com/tj-actions/sync-release-version/actions?query=workflow%3A%22Update+release+version.%22)
[![Public workflows that use this action.](https://img.shields.io/endpoint?url=https%3A%2F%2Fused-by.vercel.app%2Fapi%2Fgithub-actions%2Fused-by%3Faction%3Dtj-actions%2Fsync-release-version%26badge%3Dtrue)](https://github.com/search?o=desc\&q=tj-actions+sync-release-version+path%3A.github%2Fworkflows+language%3AYAML\&s=\&type=Code)

## sync-release-version

## Problem

With multiple files that need to be updated each time a new released is created.

`sync-release-version` makes this process less complex by using a regex pattern to match the lines in the specified files that needs to be updated.

## Helpful Resources

*   https://www.regextester.com/111539
*   https://www.tutorialspoint.com/unix/unix-regular-expressions.htm

## Usage

#### Sync a project release version number.

Update files that reference a project version with a new release number.

> [!NOTE]
>
> *   This example assumes a post release operation i.e changes are made to a README after a new version is releaased.

```yaml
...
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0 # otherwise, you will fail to push refs to dest repo

      - name: Sync release version.
        uses: tj-actions/sync-release-version@v13
          id: sync-release-version
          with:
            pattern: 'version='
            current_version: '1.0.1'  # Omit this to use git tag.
            new_version: '1.0.2'  # Omit this to use git tag.
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
        uses: tj-actions/sync-release-version@v13
        id: sync-release-version
        with:
          pattern: 'tj-actions/sync-release-version@'
          paths: |
            README.md
 
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v3
        with:
          base: "main"
          title: "Upgraded to ${{ steps.sync-release-version.outputs.new_version }}"
          branch: "upgrade-to-${{ steps.sync-release-version.outputs.new_version }}"
          commit-message: "Upgraded from ${{ steps.sync-release-version.outputs.old_version }} -> ${{ steps.sync-release-version.outputs.new_version }}"
          body: "View [CHANGES](https://github.com/${{ github.repository }}/compare/${{ steps.sync-release-version.outputs.old_version }}...${{ steps.sync-release-version.outputs.new_version }})"
          reviewers: "jackton1"
```

## Example

![Sample](https://user-images.githubusercontent.com/17484350/197892710-7238ba98-fc60-4011-a133-40e1ae1ebf7b.png)

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

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|                                     INPUT                                     |  TYPE  | REQUIRED |  DEFAULT  |                                                                  DESCRIPTION                                                                   |
|-------------------------------------------------------------------------------|--------|----------|-----------|------------------------------------------------------------------------------------------------------------------------------------------------|
| <a name="input_current_version"></a>[current\_version](#input_current_version) | string |  false   |           |                                           The current project version (Default: The last git tag).                                             |
|       <a name="input_new_version"></a>[new\_version](#input_new_version)       | string |  false   |           |                                             The next project version (Default: The new git tag).                                               |
|        <a name="input_only_major"></a>[only\_major](#input_only_major)         | string |  false   | `"false"` |                                                   Only update the major version <br>number.                                                    |
|                <a name="input_paths"></a>[paths](#input_paths)                | string |   true   |           |                                           A list of file names <br>to search and replace versions.                                             |
|             <a name="input_pattern"></a>[pattern](#input_pattern)             | string |  false   |           |                                      The pattern to match the <br>location that needs to be <br>updated.                                       |
|     <a name="input_strip_prefix"></a>[strip\_prefix](#input_strip_prefix)      | string |  false   |           | Prefix to strip from the <br>tag. For example if `strip_prefix` <br>is set to `v` and <br>the tag is `v1.0.0` the <br>output becomes `1.0.0`.  |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->

|                                          OUTPUT                                          |  TYPE  |                 DESCRIPTION                  |
|------------------------------------------------------------------------------------------|--------|----------------------------------------------|
| <a name="output_is_initial_release"></a>[is\_initial\_release](#output_is_initial_release) | string |    Boolean indicating an initial release.    |
|          <a name="output_major_update"></a>[major\_update](#output_major_update)          | string | Boolean indicating a major version <br>bump  |
|           <a name="output_new_version"></a>[new\_version](#output_new_version)            | string |         The current project version          |
|           <a name="output_old_version"></a>[old\_version](#output_old_version)            | string |         The previous project version         |

<!-- AUTO-DOC-OUTPUT:END -->

*   Free software: [MIT license](LICENSE)

If you feel generous and want to show some extra appreciation:

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

[buymeacoffee]: https://www.buymeacoffee.com/jackton1

[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png

## Features

*   Modifies files with an up to date version of your project based on each release tag.

## Known Limitation

> [!IMPORTANT]
> *  To ignore certain lines from getting updated ensure the version used doesn't match either the current or previous version.

## Credits

This package was created with [Cookiecutter](https://github.com/cookiecutter/cookiecutter).

## Report Bugs

Report bugs at https://github.com/tj-actions/sync-release-version/issues.

If you are reporting a bug, please include:

*   Your operating system name and version.
*   Any details about your workflow that might be helpful in troubleshooting.
*   Detailed steps to reproduce the bug.
