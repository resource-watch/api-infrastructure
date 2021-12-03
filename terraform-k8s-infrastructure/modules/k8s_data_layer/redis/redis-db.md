# Redis database allocation

Redis uses databases (similar to the traditional concept of a SQL database) to keep data separated. By default, it has 16 databases, numbered 0-15. This document serves to document which RW API microservice uses which database, so we avoid multiple microservices sharing the same database.

- 0: Default database. Shared by multiple microservices.
- 1: <has some koa sessions keys, not clear if CT leftovers>
- 2: GEE Tiles
- 3: Aqueduct Analysis
- 4: Not used
- 5: Not used
- 6: Not used
- 7: Not used
- 8: Not used
- 9: Not used
- 10: Not used
- 11: Not used
- 12: Not used
- 13: Not used
- 14: Not used
- 15: Not used