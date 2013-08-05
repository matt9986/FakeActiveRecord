require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class
  end

  def other_table
    @other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
      other_class_name = params[:class_name] || name.to_s.camelize
      primary_key = params[:primary_key] || "id"
      foreign_key = params[:foreign_key] || name.to_s + "_id"
      @other_class = other_class_name.constantize
      @other_table = other_class.table_name

  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params || @assoc_params = {}
  end

  def belongs_to(name, params = {})
    apc = BelongsToAssocParams.new(name, params)
    assoc_params[name] = apc

    define_method(name) do
      other_class_name = params[:class_name] || name.to_s.camelize
      primary_key = params[:primary_key] || "id"
      foreign_key = params[:foreign_key] || name.to_s + "_id"
      other_class = other_class_name.constantize
      other_table_name = other_class.table_name

      array = DBConnection.execute(<<-SQL, self.send(foreign_key.to_sym))
      SELECT *
      FROM #{other_table_name}
      WHERE #{primary_key} = ?
      SQL
      other_class.parse_all(array).first
    end
  end

  def has_many(name, params = {})
    define_method(name) do
      other_class_name = params[:class_name] || name.to_s.singularize.camelcase
      primary_key = params[:primary_key] || "id"
      foreign_key = params[:foreign_key] || self.class.to_s.tableize + "_id"
      other_class = other_class_name.constantize
      other_table_name = other_class.table_name

      array = DBConnection.execute(<<-SQL, self.send(primary_key.to_sym))
      SELECT *
      FROM #{other_table_name}
      WHERE #{foreign_key} = ?
      SQL
      other_class.parse_all(array)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name) do
      step_one = assoc_params[assoc1]
      step_two = assoc_params[assoc2]

      array = DBConnection.execute(<<-SQL, self.send(foreign_key.to_sym))
      SELECT *
      FROM #{other_table_name}
      WHERE #{primary_key} = ?
      SQL
      other_class.parse_all(array).first
  end
end
