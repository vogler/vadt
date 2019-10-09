# Versioned Algebraic Data Types

We want a type-safe way to store data and its change history automatically.
Of course we could build an app that only accepts valid input/modifications and store the data and change history into a database. However, that's a lot of code and effort since it's not generic and we have to do everything programmatically.

Just storing our data as json, yaml etc. without a schema is out (deviations, typos etc.).
We could define some schema with validation for MongoDB but that's a lot of overhead and probably not expressive enough.
Same for a relational database.

Better define data in *OCaml, Haskell or Typescript* and leverage its type system.
After edited data is type-checked we could
- save the file itself and version it
- use some ORM to save it to a database
- serialize the data to e.g. json and
  - save that as a file and version it
  - save it to some database (e.g. MongoDB, Postgres)

For history we could use
- git to version files
  - Problem: git works line-based, so if we wanted to know when some data changed, we would have to make sure that every field, list item, constructor etc. is on its own line and that we only make atomic updates. Seems pretty hard/hacky.
  - Performance: Would it get slow if we tracked every word while typing? Use [git-sizer](https://github.blog/2018-03-05-measuring-the-many-sizes-of-a-git-repository/) to inspect big repos. Fast enough for [linux](https://github.com/torvalds/linux), Windows uses [VFSForGit](https://github.com/Microsoft/VFSForGit).
- a versioned database
  - [noms](https://github.com/attic-labs/noms) (Go, "Nobody is working on this right now")
  - [irmin](https://github.com/mirage/irmin) (OCaml)
    - many storage options
    - examples seem complex, don't show how to store anything but strings or trees?
- a normal database and automatically generate tables for history
  - Problem: [evolving schema](https://en.wikipedia.org/wiki/Schema_evolution). Specify functions for migration?

Regarding the type system we also want to be able to specify functions to query the data or add computed values that could be shown in a UI. To make this generic we need subtyping or row-polymorphism.
The example in `test.ml` is `activity < sport < run` where all of them have `start` and `stop` and we want a generic `duration` for all of them.

Tests:
- OCaml `test.ml`: use objects since they have row-polymorphism
- Haskell `test.hs`: TODO play around with type classes
- Typescript `test.ts`: generate declarations with inferred types in `test.d.ts` with `tsc --sctrict -d test.ts`. Tried to get some types at runtime in `test_runtime.ts`, but probably doesn't work since it erases types when emitting JS.
