# MixQL Playground

See docs at https://github.com/mixql/mixql-test-env/blob/main/docs/modules/ROOT/pages/index.adoc

## Quick check documentation for mixql-test-env/docs

### Quick build

1. Download https://github.com/mixql/mixql-test-env. 

````
git clone https://github.com/mixql/mixql-test-env.git
cd mixql-test-env
````

2. Generate documentation from local playbook.yml

```
docker run -v $PWD:/antora --rm -t antora/antora --stacktrace antora-playbook-local.yml
```

3. Site will be generated in the ./mixql-test-env/public. Run mixql-test-env/public/index.html