require 'test/unit'
require 'fluent/test'
require 'fluent/plugin/in_postgres_replicator'

class PostgresReplicatorTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    host 127.0.0.1
    port 5432
    primary_keys id
    tag pgreplicator.db.table.${event}.${primary_keys}
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::PostgresReplicatorInput).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      create_driver('')
    }

    d = create_driver
    assert_equal '127.0.0.1', d.instance.host
    assert_equal 5432, d.instance.port
    assert_equal [ 'id' ], d.instance.primary_keys
    assert_equal 'pgreplicator.db.table.${event}.${primary_keys}', d.instance.tag
  end

end
