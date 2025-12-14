# commonlib

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

## Description

Common helper functions

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Dmitrii Bogomolnyi | <nex1gen@yandex.ru> | <https://github.com/nex1gen> |

## Contribute

Don't forget to generate every time actual README.md:

```bash
helm-docs --template-files=README.md.gotmpl
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonlib.volumes.logs.mountPath | string | `"/logs"` | logs volume mount path |
| commonlib.volumes.logs.sizeLimit | string | `"128Mi"` | logs volume size limit |
| commonlib.volumes.tmp.mountPath | string | `"/tmp"` | tmp volume mount path |
| commonlib.volumes.tmp.sizeLimit | string | `"128Mi"` | tmp volume size limit |
