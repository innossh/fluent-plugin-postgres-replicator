# Fluent::Plugin::PostgresReplicator, a plugin for [Fluentd](http://www.fluentd.org)

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-postgres-replicator.svg)](https://badge.fury.io/rb/fluent-plugin-postgres-replicator)
[![Build Status](https://travis-ci.org/innossh/fluent-plugin-postgres-replicator.svg?branch=master)](https://travis-ci.org/innossh/fluent-plugin-postgres-replicator)

Fluentd input plugin to track insert/update event from PostgreSQL.

## Requirements

| fluent-plugin-postgres-replicator | fluentd | ruby |
|-----------------------------------|---------|------|
| >= 0.1.0 | >= v0.14.0 | >= 2.1 |
|  < 0.1.0 | >= v0.12.0 | >= 1.9 |

## Installation

```sh
$ apt-get install libpq-dev

$ gem install fluent-plugin-postgres-replicator
```

## Configuration

```
<source>
  @type postgres_replicator
  host localhost
  username pipeline
  password pipeline
  database pipeline
  sql SELECT hour, project, total_pages from wiki_stats;
  primary_keys hour,project
  interval 1m
  tag replicator.pipeline.wiki_stats.${event}.${primary_keys}
</source>
```

## Contributing

Bug reports and pull requests are welcome.

You can run the test on your machine as below.

```console
$ docker run --name fluent-plugin-postgres-replicator-testing -e POSTGRES_DB=pg_repli_test_db -p 5432:5432 -d postgres:9.4.12-alpine
$ psql -c 'create table pg_repli_test_table (id int8 primary key, total int8) ;' -U postgres -h 127.0.0.1 -d pg_repli_test_db
$ psql -c 'insert into pg_repli_test_table values (1, 10) ;' -U postgres -h 127.0.0.1 -d pg_repli_test_db
$ psql -c 'insert into pg_repli_test_table values (2, 20) ;' -U postgres -h 127.0.0.1 -d pg_repli_test_db

$ bundle install --path vendor/bundle
$ bundle exec rake test
```

## License

- Copyright (c) 2016 innossh
- [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
