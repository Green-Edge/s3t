# s3t

![CI](https://github.com/Green-Edge/s3t/workflows/CI/badge.svg)

`s3t` is a basic S3 testing tool.

## Installation

This tool requires a recent version of Crystal (0.35.1 as of this time).

To build, follow the standard Crystal build process:

```shell
# shards install
# crystal build --progress --release --no-debug src/s3t.cr
```

This will produce a single `s3t` binary that can then be moved
to somewhere in your `PATH`, for example `/usr/local/bin`.

### Build issues

If you find that you have build issues related to `libssl` on macOS,
try adding the following to your environment (assuming `libssl` was
installed via `brew`):

```
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/openssl/lib/pkgconfig
```

## Usage

```shell
# s3t -c config.yml
```

### Config file

The config file is a simple yaml file in the following format:

```yaml
service:
  endpoint: # str: the host/endpoint for storage
  keys:
    access: # str: the access key
    secret: # str: the secret key
storage:
  bucket: # str: name of bucket to use, will be created if necessary
  upload: # str: path to file to use for storage & verification
limits:
  concurrency: # int: number of concurrent uploads to run [default: 10]
  count: # int: max number of objects.
  per_dir: # int: max items per directory
```

Note: for integer values, underscores can be used as separators to
make them more readable.

## Testing

### Dependencies

To run tests, [`s3rver`][s3rver] should be installed and findable
in your `PATH`.

### Running tests

Clone the repository, `cd` into the directory, and execute:

```shell
# crystal spec
```

The test suite will start up and tear-down `s3rver` automatically, creating
a temporary directory in your `TEMPDIR` for storing test files.

**NOTE:** this temporary directory is **not** removed as part of the tear-down
step. You should remember to do this manually at the end of each test run, after
any verification steps you wish to take.


## Contributing

1.  Fork it (https://github.com/Green-Edge/s3t/fork)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new pull request

## Liability

We take no responsibility for the use of our tool, or external
instances provided by third parties. We strongly recommend you abide
by the valid official regulations in your country. Furthermore, we
refuse liability for any inappropriate or malicious use of this
tool. This tool is provided to you in the spirit of free, open
software.

You may view the LICENSE in which this software is provided to you
[here](./LICENSE).

> 8. Limitation of Liability. In no event and under no legal theory,
>    whether in tort (including negligence), contract, or otherwise,
>    unless required by applicable law (such as deliberate and grossly
>    negligent acts) or agreed to in writing, shall any Contributor be
>    liable to You for damages, including any direct, indirect, special,
>    incidental, or consequential damages of any character arising as a
>    result of this License or out of the use or inability to use the
>    Work (including but not limited to damages for loss of goodwill,
>    work stoppage, computer failure or malfunction, or any and all
>    other commercial damages or losses), even if such Contributor
>    has been advised of the possibility of such damages.



[s3rver]: https://github.com/jamhall/s3rver
