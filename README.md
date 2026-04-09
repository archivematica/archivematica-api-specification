# archivematica-api-specification

Welcome to the repository for the Archivematica API specification. This
repository defines the Archivematica API using [TypeSpec.io], which we then use
to generate an OpenAPI v3 specification.

From the OpenAPI specification, it is possible to generate clients, server
stubs, and documentation in multiple languages thanks to extensive community
support.

Although the Archivematica API design may not always adhere to best practices,
we hope this repository provides a detailed and transparent description of these
imperfections.

The [Archivematica Storage Service API] specification is also available.

## Usage

```
npm --prefix=typespec run compile
```

## OpenAPI specification

You can browse the OpenAPI specification in two forms:

- [Interactive OpenAPI docs][openapi-docs]
- [Raw OpenAPI YAML][openapi-schema]

The specification is still incomplete, and we expect to extend it over time as
we cover more of the API.

## Resources

- [Current documentation](https://www.archivematica.org/en/docs/latest/dev-manual/api/api-reference-archivematica/)
  \- not entirely accurate.
- [Legacy documentation](https://wiki.archivematica.org/Archivematica_API) -
  abandoned, outdated.
- [Dashboard API Django app](https://github.com/artefactual/archivematica/tree/qa/1.x/src/archivematica/dashboard/components/api)
  \- the source code!

[archivematica storage service api]: https://github.com/archivematica/archivematica-storage-service-api-specification
[openapi-docs]: https://archivematica.github.io/archivematica-api-specification/
[openapi-schema]: https://raw.githubusercontent.com/archivematica/archivematica-api-specification/refs/heads/main/typespec/tsp-output/%40typespec/openapi3/openapi.v1.yaml
[typespec.io]: https://typespec.io
