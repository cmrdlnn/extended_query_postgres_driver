# frozen_string_literal: true

require 'benchmark'
require 'benchmark-memory'
require 'pg'
require_relative '../lib/extended_query_postgres_driver'

# Configuring the library to connect to the database
ExtendedQueryPostgresDriver.configure do |config|
  config.database = 'test_database'
  config.user     = 'test_user'
  config.password = '123456'
end

# Creating of library connection instance and sending the startup message to
# server
conn = ExtendedQueryPostgresDriver::Connection.new
conn.parse(
  statement: 'create_file',
  oids:      [17],
  query:     'INSERT INTO files(content) VALUES ($1);'
)
conn.sync

def create_file(connection, filename)
  file = File.open(File.join(__dir__, filename))
  connection.bind(
    format_codes: [1],
    parameters:   [file],
    statement:    'create_file'
  )
  connection.execute
  connection.sync
  connection.result
end

GC.start
sleep(5)

Benchmark.bm(62) do |x|
  x.report('create 6,1 kB `iso_8859-1.txt` file by this library') do
    create_file(conn, 'iso_8859-1.txt')
  end
  x.report('create 120,1 kB `maxresdefault.jpg` file by this library') do
    create_file(conn, 'maxresdefault.jpg')
  end
  x.report('create 967,0 kB `SFTBR-04U.PDF` file by this library') do
    create_file(conn, 'SFTBR-04U.PDF')
  end
  x.report('create 6,5 MB `big.txt` file by this library') do
    create_file(conn, 'big.txt')
  end
  x.report('create 10,5 MB `SampleZIPFile_10mbmb.zip` file by this library') do
    create_file(conn, 'SampleZIPFile_10mbmb.zip')
  end
  x.report('create 14,2 MB `Sample_large_docx.docx` file by this library') do
    create_file(conn, 'Sample_large_docx.docx')
  end
  x.report('create 31,6 MB `codpaste-teachingpack.pdf` file by this library') do
    create_file(conn, 'codpaste-teachingpack.pdf')
  end
end

GC.start
sleep(5)

Benchmark.memory do |x|
  x.report('create 6,1 kB `iso_8859-1.txt` file by this library') do
    create_file(conn, 'iso_8859-1.txt')
  end
  x.report('create 120,1 kB `maxresdefault.jpg` file by this library') do
    create_file(conn, 'maxresdefault.jpg')
  end
  x.report('create 967,0 kB `SFTBR-04U.PDF` file by this library') do
    create_file(conn, 'SFTBR-04U.PDF')
  end
  x.report('create 6,5 MB `big.txt` file by this library') do
    create_file(conn, 'big.txt')
  end
  x.report('create 10,5 MB `SampleZIPFile_10mbmb.zip` file by this library') do
    create_file(conn, 'SampleZIPFile_10mbmb.zip')
  end
  x.report('create 14,2 MB `Sample_large_docx.docx` file by this library') do
    create_file(conn, 'Sample_large_docx.docx')
  end
  x.report('create 31,6 MB `codpaste-teachingpack.pdf` file by this library') do
    create_file(conn, 'codpaste-teachingpack.pdf')
  end
end

conn.close
GC.start
sleep(5)

conn = PG.connect(
  dbname:   'test_database',
  user:     'test_user',
  host:     'localhost',
  password: '123456'
)
conn.prepare('create_file', 'INSERT INTO files(content) VALUES ($1);', [17])

def create_by_pg_gem(connection, filename)
  file = File.read(File.join(__dir__, filename))
  connection.exec_prepared('create_file', [{ value: file, format: 1 }])
end

GC.start
sleep(5)

Benchmark.bm(62) do |x|
  x.report('create 6,1 kB `iso_8859-1.txt` file by `pg` gem') do
    create_by_pg_gem(conn, 'iso_8859-1.txt')
  end
  x.report('create 120,1 kB `maxresdefault.jpg` file by `pg` gem') do
    create_by_pg_gem(conn, 'maxresdefault.jpg')
  end
  x.report('create 967,0 kB `SFTBR-04U.PDF` file by `pg` gem') do
    create_by_pg_gem(conn, 'SFTBR-04U.PDF')
  end
  x.report('create 6,5 MB `big.txt` file by `pg` gem') do
    create_by_pg_gem(conn, 'big.txt')
  end
  x.report('create 10,5 MB `SampleZIPFile_10mbmb.zip` file by `pg` gem') do
    create_by_pg_gem(conn, 'SampleZIPFile_10mbmb.zip')
  end
  x.report('create 14,2 MB `Sample_large_docx.docx` file by `pg` gem') do
    create_by_pg_gem(conn, 'Sample_large_docx.docx')
  end
  x.report('create 31,6 MB `codpaste-teachingpack.pdf` file by `pg` gem') do
    create_by_pg_gem(conn, 'codpaste-teachingpack.pdf')
  end
end

GC.start
sleep(5)

Benchmark.memory do |x|
  x.report('create 6,1 kB `iso_8859-1.txt` file by `pg` gem') do
    create_by_pg_gem(conn, 'iso_8859-1.txt')
  end
  x.report('create 120,1 kB `maxresdefault.jpg` file by `pg` gem') do
    create_by_pg_gem(conn, 'maxresdefault.jpg')
  end
  x.report('create 967,0 kB `SFTBR-04U.PDF` file by `pg` gem') do
    create_by_pg_gem(conn, 'SFTBR-04U.PDF')
  end
  x.report('create 6,5 MB `big.txt` file by `pg` gem') do
    create_by_pg_gem(conn, 'big.txt')
  end
  x.report('create 10,5 MB `SampleZIPFile_10mbmb.zip` file by `pg` gem') do
    create_by_pg_gem(conn, 'SampleZIPFile_10mbmb.zip')
  end
  x.report('create 14,2 MB `Sample_large_docx.docx` file by `pg` gem') do
    create_by_pg_gem(conn, 'Sample_large_docx.docx')
  end
  x.report('create 31,6 MB `codpaste-teachingpack.pdf` file by `pg` gem') do
    create_by_pg_gem(conn, 'codpaste-teachingpack.pdf')
  end
end
