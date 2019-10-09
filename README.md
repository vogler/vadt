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

For **history** we could use
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

Regarding the **type system** we also want to be able to specify functions to query the data or add computed values that could be shown in a UI. To make this generic we need subtyping or row-polymorphism.
The example in `test.ml` is `activity < sport < run` where all of them have `start` and `stop` and we want a generic `duration` for all of them.
We can add `duration`
1. in object at definition (include/mixin, Java: extend abstract class)
2. outside object (subtyping, duck typing, Java: interface)
3. in object after definition (row polymorphism with access to row variable)

For approach 3 we mean one function that works on all subtypes without limiting the result to the extended base type. We could of course have one function for each type to extend, but then we could just use approach 1 if we don't need to do it dynamically.

Tests:
- Java `test.java` [1, 2]
- OCaml `test.ml` [1, 2]: use objects since they have row-polymorphism
  - 1 ok, but a bit verbose compared to abstract class in Java
  - 2 ok
  - 3 can't extend object, only class
- Haskell `test.hs`: TODO play around with type classes
- Typescript `test.ts` [1, 2, 3?]:

It would be nice to be able to start writing data and get the inferred structural types as a starting point to make them into more abstract types.

- Typescript: generate declarations with inferred types in `test.d.ts` with `tsc --sctrict -d test.ts`. Tried to get some types at runtime in `test_runtime.ts`, but probably doesn't work since it erases types when emitting JS.


## Resources
- OCaml
  - serialization
    - [ppx_deriving](https://github.com/ocaml-ppx/ppx_deriving) needs annotation on every type :(
      - [ppx_autoserialize](https://github.com/jaredly/ppx_autoserialize) does not; works for OCaml?
    - [milk](https://github.com/jaredly/milk) ([blog post](https://jaredforsyth.com/posts/announcing-milk/)) generates code for de/serialization in extra file, config with `types.json`, needs to be rerun when types change (no ppx), but supports ppx annotations for migrating types.
