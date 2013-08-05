require_relative './db_connection'

module Searchable
  def where(params)
  	key_array = params.keys.map{ |key| key.to_s + "= ?"}
  	array = DBConnection.execute(<<-SQL, *params.values)
    SELECT *
    FROM #{table_name}
    WHERE #{key_array.join(" AND ")}
    SQL
    self.parse_all(array)
  end
end