# Versioned Algebraic Data Types

Want to store data with history.
- Store data in files and version with git:
  - Use json or yaml files -> no schema and nothing that checks for errors or deviations (e.g. typos in field names), no uniform structure for search
  - Scales well enough? If it works for linux, it's probably fine for my use cases. https://github.blog/2018-03-05-measuring-the-many-sizes-of-a-git-repository/: `git-sizer`
- Store data in database and version with it:
  - Schema:
    - no schema, i.e. use some NoSQL document store like MongoDB -> same problem as above with using json files. What about relational data? Embed? What about cycles? References?
    - with schema, i.e. some relational DB -> have to create schema for tables, is there something that can infer this from the data? What if the schema changes?
  - Versioning bal
    - Use a versioned database. How do they work? https://en.wikipedia.org/wiki/Temporal_database more in the way of time series database?
    - Generate tables for history -> hard to deal with [evolving schema](https://en.wikipedia.org/wiki/Schema_evolution), lot of programming overhead.

Looking for a type-safe way to store documents and their history.
Type-safe -> use OCaml GADTs
History -> git or versioned database?

- Put data in .ml files, run the compiler on it and commit to git only if there are no errors.
