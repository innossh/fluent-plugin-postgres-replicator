# Fluent::Plugin::PostgresReplicator, a plugin for [Fluentd](http://www.fluentd.org)

Fluentd input plugin to track insert/update event from PostgreSQL.

## Installation

```sh
$ gem install fluent-plugin-postgres-replicator
```

## Usage

In your Fluentd configuration, use `type postgres_replicator`.  
Default values would look like this:

```
<source>
  type postgres_replicator
  host localhost
  username pipeline
  password pipeline
  database pipeline
  query SELECT hour, project, total_pages from wiki_stats;
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
