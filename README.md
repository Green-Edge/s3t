# s3t

![CI](https://github.com/Green-Edge/s3t/workflows/CI/badge.svg)

`s3t` is a basic S3 testing tool.

## Usage

```bash
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

```bash
# crystal spec
```

The test suite will start up and tear-down `s3rver` automatically, creating
a temporary directory in your `TEMPDIR` for storing test files.

**NOTE:** this temporary directory is **not** removed as part of the tear-down
step. You should remember to do this manually at the end of each test run, after
any verification steps you wish to take.
