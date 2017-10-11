require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |el| "#{el} = ?"}.join(' AND ')
    valuess = params.values.map(&:to_s)
    where_query = DBConnection.execute(<<-SQL, *valuess)
      SELECT *
      FROM #{table_name}
      WHERE #{where_line}
    SQL

    parse_all(where_query)
  end
end

class SQLObject
  extend Searchable
  include Searchable
end
