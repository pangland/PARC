require_relative 'db_connection'
require 'active_support/inflector'
require_relative 'searchable'
require_relative 'associatable'

class SQLObject
  def self.columns
    return @columns unless @columns.nil?

    @columns = []
    terrible_naming_convention = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL

    @columns = terrible_naming_convention[0].map{ |el| el.to_sym }

  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column.to_s}=".to_sym) do |val|
        self.attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    hashes = DBConnection.execute(<<-SQL)
      SELECT *
      FROM "#{self.table_name}"
    SQL

    self.parse_all(hashes)
  end

  def self.parse_all(results)
    final_answer = []
    results.each do |result|
      final_answer << self.new(result)
    end

    final_answer
  end

  def self.find(id)
    self.all.find { |obj| obj.id == id }
  end

  def initialize(params = {})
    params.each do |key, value|
      key = key.to_sym
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key)
      self.send("#{key}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    col_names = self.class.columns
    col_names = col_names.reject { |el| el == :id }.join(',')
    attributes_present = attribute_values.reject(&:nil?)
    question_marks = (['?'] * attributes_present.length).join(',')
    DBConnection.execute(<<-SQL, *attributes_present)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns
    set_thing = col_names.map { |el| "#{el} = ?" }.join(',')
    attributes_present = attribute_values.reject(&:nil?)

    DBConnection.execute(<<-SQL, *attributes_present, self.id)
      UPDATE #{self.class.table_name}
      SET #{set_thing}
      WHERE id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
