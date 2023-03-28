# Bigtop Hadoop playground

See docs at https://github.com/ntlegion/mixql-test-env/blob/main/docs/modules/ROOT/pages/index.adoc

# Quick check documentation for mixql-test-env/docs

## Quick build

1. Download mixql-test-env. Site will be generated in the mixql-test-env/public.
2. Generate documentation from local playbook.yml

```
docker run -v $PWD:/antora --rm -t antora/antora --stacktrace antora-playbook-local.yml
```

3. Run mixql-test-env/public/index.html