![CI](https://github.com/tj-actions/bumpversion/workflows/CI/badge.svg)
![Update release version.](https://github.com/tj-actions/bumpversion/workflows/Update%20release%20version./badge.svg)

bumpversion
-----------

#### Sync a project release version number.

Update files that reference a project version with a new release number.

```yaml
...

    steps:
      - uses: actions/checkout@v2
      - name: Bumpversion release version.
        uses: tj-actions/bumpversion@v6.8
          id: bumpversion
          with:
            current_version: '1.0.1'  # Omit to use git tag.
            new_version: '1.0.2'  # Omit when running on a release action.
            paths: |
              README.md
              test/subdir/README.md
      - run: |
        echo "Upgraded from ${{ steps.bumpversion.outputs.old_version }} -> ${{ steps.bumpversion.outputs.new_version }}" 
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
      - name: Bumpversion release version.
        uses: tj-actions/bumpversion@v6.8
        id: bumpversion
        with:
          commit: true
          pattern: 'tj-actions/bumpversion@'
          paths: |
            README.md
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v3
        with:
          base: "master"
          title: "Upgraded to ${{ steps.bumpversion.outputs.new_version }}"
          branch: "upgrade-to-${{ steps.bumpversion.outputs.new_version }}"
          commit-message: "Upgraded from ${{ steps.bumpversion.outputs.old_version }} -> ${{ steps.bumpversion.outputs.new_version }}"
```






* Free software: [MIT license](LICENSE)

Features
--------

* Updates your readme file with an up to date version of your project based on each release tag.



Credits
-------

This package was created with [Cookiecutter](https://github.com/cookiecutter/cookiecutter).



Report Bugs
-----------

Report bugs at https://github.com/tj-actions/bumpversion/issues.

If you are reporting a bug, please include:

* Your operating system name and version.
* Any details about your workflow that might be helpful in troubleshooting.
* Detailed steps to reproduce the bug.
