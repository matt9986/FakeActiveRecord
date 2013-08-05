require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    array = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{table_name}
    SQL
    self.parse_all(array)
  end

  def self.find(id)
    array = DBConnection.execute(<<-SQL, id)
    SELECT *
    FROM #{table_name}
    WHERE id = ?
    SQL
    self.new(array.first)
  end

  def save
    if id.nil?
      self.send(:create)
    else
      self.send(:update)
    end
  end

  private

  def create
    question_marks = ["?"] * self.class.attributes.length
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO #{self.class.table_name}
    (#{self.class.attributes.join(", ")})
    VALUES (#{question_marks.join(", ")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    question_marks = ["?"] * self.class.attributes.length
    DBConnection.execute(<<-SQL, *attribute_values)
    UPDATE #{ self.class.table_name }
    SET #{ self.class.attributes.map{ |name| name.to_s + "= ?" }.join(", ") }
    WHERE id = #{ self.id }
    SQL
  end

  def attribute_values
    self.class.attributes.map{ |name| self.send(name) }
  end
end
