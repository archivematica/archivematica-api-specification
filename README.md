# archivematica-api-specification

Welcome to the repository for the Archivematica API specification. This
documentation describes our API using [TypeSpec.io], which we then use to
generate the OpenAPI v3 specification.

From the OpenAPI specification, it is possible to create clients, servers or
documentation in multiple languages thanks to extensive support from the
community.

Although the Archivematica API design may not always adhere to best practices,
we hope this repository provides a detailed and transparent desription of these
imperfections.

The [Archivematica Storage Service API] specification is also available.

## Usage

    npm --prefix=typespec run compile

## OpenAPI specification

Check out the results [here].

## Resources

- [Current documentation](https://www.archivematica.org/en/docs/latest/dev-manual/api/api-reference-archivematica/) - not entirely accurate.
- [Legacy documentaton](https://wiki.archivematica.org/Archivematica_API) - abandoned, outdated.
- [Dashboard API Django app](https://github.com/artefactual/archivematica/tree/qa/1.x/src/archivematica/dashboard/components/api) - the source code!

[here]: https://editor.swagger.io/?url=https://raw.githubusercontent.com/archivematica/archivematica-api-specification/main/typespec/tsp-output/%40typespec/openapi3/openapi.v1.yaml
[TypeSpec.io]: https://typespec.io
[Archivematica Storage Service API]: https://github.com/archivematica/archivematica-storage-service-api-specification
