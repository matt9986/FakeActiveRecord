require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
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
    array.map{|row_hash| self.new(row_hash)}
  end

  def self.find(id)
    array = DBConnection.execute(<<-SQL, id)
    SELECT *
    FROM #{table_name}
    WHERE id = ?
    SQL
    self.new(array.first)
  end

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

  def save
    if id.nil?
      self.create
    else
      self.update
    end
  end

  def attribute_values
    self.class.attributes.map{ |name| self.send(name) }
  end
end
