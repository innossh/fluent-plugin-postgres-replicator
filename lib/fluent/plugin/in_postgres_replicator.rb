class Fluent::PostgresReplicatorInput < Fluent::Input
  Fluent::Plugin.register_output('postgres_replicator', self)

end
