# Fluent::Plugin::PostgresReplicator, a plugin for [Fluentd](http://www.fluentd.org)

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-postgres-replicator.svg)](https://badge.fury.io/rb/fluent-plugin-postgres-replicator)
[![Build Status](https://travis-ci.org/innossh/fluent-plugin-postgres-replicator.svg?branch=master)](https://travis-ci.org/innossh/fluent-plugin-postgres-replicator)

Fluentd input plugin to track insert/update event from PostgreSQL.

## Installation

```sh
# requirements
$ apt-get install libpq-dev

$ gem install fluent-plugin-postgres-replicator
```

## Configuration

```
<source>
  type postgres_replicator
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

## License

- Copyright (c) 2016 innossh
- [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
