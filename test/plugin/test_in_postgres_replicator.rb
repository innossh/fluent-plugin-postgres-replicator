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
    username postgres
    database pg_repli_test_db
    sql SELECT id, total from pg_repli_test_table;
    interval 1s
    primary_keys id
    tag pgreplicator.postgres.pg_repli_test_table.${event}.${primary_keys}
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
    assert_equal 'postgres', d.instance.username
    assert_equal nil, d.instance.password
    assert_equal 'pg_repli_test_db', d.instance.database
    assert_equal 'SELECT id, total from pg_repli_test_table;', d.instance.sql
    assert_equal 1, d.instance.interval
    assert_equal ['id'], d.instance.primary_keys
    assert_equal 'pgreplicator.postgres.pg_repli_test_table.${event}.${primary_keys}', d.instance.tag
  end

  def test_emit
    d = create_driver

    d.run do
      sleep 2
    end

    emits = d.emits
    assert_equal true, emits.length > 0
    assert_equal 'pgreplicator.postgres.pg_repli_test_table.insert.id', emits[0][0]
    assert_equal ({'id' => '1', 'total' => '10'}), emits[0][2]
    assert_equal 'pgreplicator.postgres.pg_repli_test_table.insert.id', emits[1][0]
    assert_equal ({'id' => '2', 'total' => '20'}), emits[1][2]
  end

end
