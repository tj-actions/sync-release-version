![CI](https://github.com/tj-actions/bumpversion/workflows/CI/badge.svg)
![Update release version.](https://github.com/tj-actions/bumpversion/workflows/Update%20release%20version./badge.svg)

bumpversion
-----------

Sync release version.

Update files that reference a project version with a new release number.

```yaml
...

    steps:
      - uses: actions/checkout@v3
      - name: Bumpversion release version.
        uses: tj-actions/bumpversion@v0.1a
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

* TODO


Credits
-------

This package was created with Cookiecutter.



Report Bugs
-----------

Report bugs at https://github.com/tj-actions/bumpversion/issues.

If you are reporting a bug, please include:

* Your operating system name and version.
* Any details about your workflow that might be helpful in troubleshooting.
* Detailed steps to reproduce the bug.
