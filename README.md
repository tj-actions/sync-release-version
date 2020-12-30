![CI](https://github.com/tj-actions/bumpversion/workflows/CI/badge.svg)
![Update release version.](https://github.com/tj-actions/bumpversion/workflows/Update%20release%20version./badge.svg)

bumpversion
-----------

> :warning: This is currently unstable future goal would be to create a pull request based on the changes made that can be reviewed.

Sync release version.

Real Example Usage: [sample](.github/workflows/release.yml)

Update files that reference a project version with a new release number.

```yaml
...

    steps:
      - uses: actions/checkout@v2
      - name: Bumpversion release version.
        uses: tj-actions/bumpversion@v6.1-alpha
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




* Free software: [MIT license](LICENSE)

Features
--------

* Updates your readme file with an up to date version of your project based on each release tag.



Todo's
------

- [ ] Add support to create a pull request based on the changes made to files.


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
