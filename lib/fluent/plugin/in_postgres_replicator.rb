class Fluent::PostgresReplicatorInput < Fluent::Input
  Fluent::Plugin.register_input('postgres_replicator', self)

  config_param :host, :string, :default => 'localhost'
  config_param :port, :integer, :default => 5432
  config_param :username, :string, :default => 'root'
  config_param :password, :string, :default => nil, :secret => true
  config_param :database, :string, :default => nil
  config_param :sql, :string, :default => nil
  config_param :primary_keys, :string, :default => nil
  config_param :interval, :string, :default => '10s'
  config_param :tag, :string, :default => nil

  def initialize
    super
    require 'pg'
    require 'digest/sha1'
  end

  def configure(conf)
    super
    @interval = Fluent::Config.time_value(@interval)
    if @primary_keys.nil?
      raise Fluent::ConfigError, "primary_keys MUST be specified"
    end
    if @tag.nil?
      raise Fluent::ConfigError, "tag MUST be specified"
    end
    @primary_keys = @primary_keys.split(/\s*,\s*/)
  end

  def start
    @thread = Thread.new(&method(:run))
  end

  def shutdown
    Thread.kill(@thread)
  end

  def run
    begin
      poll
    rescue StandardError => e
      $log.error "failed to execute query. error: #{e.message}"
      $log.error e.backtrace.join("\n")
    end
  end

  def poll
    hash_values = Hash.new
    conn = get_connection()
    loop do
      rows_count = 0
      start_time = Time.now
      rows, conn = query(@sql, conn)
      rows.each do |row|
        row_ids = Array.new
        @primary_keys.each do |primary_key|
          if row[primary_key].nil?
            $log.error "primary_key value is not found. :tag=>#{@tag} :primary_key=>#{primary_key}"
            break
          end
          row_ids << row[primary_key]
        end

        hash_value_id = row_ids.join('_')
        hash_value = Digest::SHA1.hexdigest(row.flatten.join)
        if !hash_values.include?(hash_value_id)
          tag = format_tag(@tag, {:event => :insert})
          emit_record(tag, row)
        elsif hash_values[hash_value_id] != hash_value
          tag = format_tag(@tag, {:event => :update})
          emit_record(tag, row)
        end
        hash_values[hash_value_id] = hash_value
        rows_count += 1
      end
      conn.close
      elapsed_time = sprintf('%0.02f', Time.now - start_time)
      $log.info "success to execute replicator. :tag=>#{@tag} :rows_count=>#{rows_count} :elapsed_time=>#{elapsed_time} sec"
      sleep @interval
    end

  end

  def query(query, conn = nil)
    begin
      conn = (conn.nil? || conn.finished?) ? get_connection : conn
      return conn.query(query), conn
    rescue Exception => e
      $log.warn "failed to execute query and will retry. error: #{e}"
      sleep @interval
      retry
    end
  end

  def format_tag(tag, param)
    pattern = {'${event}' => param[:event].to_s, '${primary_keys}' => @primary_keys.join('_')}
    tag.gsub(/(\${[a-z_]+})/) do
      $log.warn "placeholder value is not found. :tag=>#{tag} :placeholder=>#{$1}" unless pattern.include?($1)
      pattern[$1]
    end
  end

  def emit_record(tag, record)
    router.emit(tag, Fluent::Engine.now, record)
  end

  def get_connection
    begin
      return PG::Connection.new({
        :host => @host,
        :port => @port,
        :user => @username,
        :password => @password,
        :dbname => @database
      })
    rescue Exception => e
      $log.warn "failed to get connection and will retry. error: #{e}"
      sleep @interval
      retry
    end
  end
end
