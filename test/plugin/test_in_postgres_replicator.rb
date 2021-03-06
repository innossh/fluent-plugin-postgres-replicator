require 'fluent/test'
require 'fluent/test/driver/input'
require 'fluent/plugin/in_postgres_replicator'

class PostgresReplicatorTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  CONFIG = %[
    host 127.0.0.1
    port 5432
    username postgres
    database pg_repli_test_db
    sql SELECT id, total from pg_repli_test_table;
    interval 1s
    primary_keys id
    tag pgreplicator.pg_repli_test_db.pg_repli_test_table.${event}.${primary_keys}
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::PostgresReplicatorInput).configure(conf)
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
    assert_equal 'pgreplicator.pg_repli_test_db.pg_repli_test_table.${event}.${primary_keys}', d.instance.tag
  end

  def test_emit
    d = create_driver

    d.run(expect_records: 2, timeout: 2)

    events = d.events
    assert_equal true, events.length == 2
    assert_equal ['pgreplicator.pg_repli_test_db.pg_repli_test_table.insert.id', @time, {'id' => '1', 'total' => '10'}], events[0]
    assert_equal ['pgreplicator.pg_repli_test_db.pg_repli_test_table.insert.id', @time, {'id' => '2', 'total' => '20'}], events[1]
  end

end
