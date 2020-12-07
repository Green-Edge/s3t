# s3t

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
