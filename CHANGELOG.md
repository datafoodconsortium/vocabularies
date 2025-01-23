# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

in vocabulary.rdf & vocabulary.json
- transformationType  with subconcept : accept, combine, consume, dropoff, lower, modify, move, pickup, produce, raise, separate, use

in ProductTypes.rdf & ProductTypes.json:
 - `medlar` as narrower of `fruit`
 - `strawberry` as narrower of `fruit`
 - `pulse` as narrower of `dried_goods`
 - `snack` as narrower of `savory-groceries`
 - `grain` as narrower of `savory-groceries`
 - `cannedGoods` as narrower of `savory-groceries`
 - `ferment` as narrower of `savory-groceries`
 - `dried_goods` as narrower of `local-grocery-store`

### Changed

Included new exports of facets.rdf, measures.rdf, productTypes.rdf & vocabulary.rdf following VOCbench upgrade

### Fixed

in ProductTypes.rdf & ProductTypes.json:
- Replaced `chewed-up` with `corn-salad` as narrower of `salad`
- Replaced `old-variety-tomato` with `heirloom-tomato` as narrower of `tomato`

in vocabulary.rdf & vocabulary.json:
- added `SKOS:narrower` for all concepts.
- added `skos:hasTopConcept` for scheme.

## [1.2.0] - 2024-02-04

### Added

in facets.rdf & facets.json
- TerritorialOrgin : subconcepts related to Administrative Regions & Ceremonial Counties (incomplete) for England & Scotland

## [1.1.0] - 2023-12-22

### Added

- vocabulary.rdf
- vocabulary.json
- Chicken in Facets
- ChickenPart in Facets

### Fixed
- Roster URI replace by Rooster URI in Facets

## [1.0.2] - 2023-09-13

### Fixed

- Measures.json was containing productTypes (issue #4).

## [1.0.1] - 2023-06-30

### Changed

- Change the base URI of JSON and RDF files (now using https://github.com/datafoodconsortium/taxonomies/releases/latest/download/ instead of https://static.datafoodconsortium.org/data/).
- Updated the README.md file (contributing process and details).

## [1.0.0] - 2023-02-06

### Added

- This is the initial version: we extracted this from the `/data` folder of the [DFC ontology](https://github.com/datafoodconsortium/ontology) repository.

[unreleased]: https://github.com/datafoodconsortium/taxonomies/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/datafoodconsortium/taxonomies/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/datafoodconsortium/taxonomies/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/datafoodconsortium/taxonomies/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/datafoodconsortium/taxonomies/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/datafoodconsortium/taxonomies/releases/tag/v1.0.0
