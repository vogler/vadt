# Versioned Algebraic Data Types

Want to store data with history.
- Store data in *files* and version with *git*:
  - Use json or yaml files -> no schema and nothing that checks for errors or deviations (e.g. typos in field names), no uniform structure for search
  - Scales well enough? If it works for linux, it's probably fine for my use cases. https://github.blog/2018-03-05-measuring-the-many-sizes-of-a-git-repository/: `git-sizer`
- Store data in *database* and version with it:
  - Schema:
    - no schema, i.e. use some NoSQL document store like MongoDB -> same problem as above with using json files. What about relational data? Embed? What about cycles? References?
    - with schema, i.e. some relational DB -> have to create schema for tables, is there something that can infer this from the data? What if the schema changes?
  - Versioning:
    - Use a versioned database. How do they work? https://en.wikipedia.org/wiki/Temporal_database more in the way of time series database?
      - https://github.com/mirage/irmin
      - https://github.com/attic-labs/noms
    - Generate tables for history -> hard to deal with [evolving schema](https://en.wikipedia.org/wiki/Schema_evolution), lot of programming overhead.

Looking for a type-safe way to store documents and their history.
- Type-safe -> use OCaml GADTs
- History -> git or (versioned) database

Versioned databases:
- https://github.com/attic-labs/noms (Go, "Nobody is working on this right now")
- https://github.com/mirage/irmin (OCaml)
  - many storage options
  - examples seem complex, don't show how to store anything but strings or trees?

Ideas:
- Put data in .ml files, run the compiler on it and commit to git only (or save back to database) if there are no errors.

Tests:
- OCaml `test.ml`: use objects since they have row-polymorphism
- Haskell `test.hs`: TODO play around with type classes
- Typescript `test.ts`: generate declarations with inferred types in `test.d.ts` with `tsc --sctrict -d test.ts`. Tried to get some types at runtime in `test_runtime.ts`, but probably doesn't work since it erases types when emitting JS.
