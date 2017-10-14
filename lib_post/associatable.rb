require_relative 'searchable'
require 'active_support/inflector'
require 'byebug'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.to_s.constantize
  end

  def table_name
    @class_name.to_s.constantize.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    class_name = name.to_s.singularize.underscore.camelcase.downcase
    @foreign_key = "#{class_name}_id".to_sym
    @primary_key = "id".to_sym
    @class_name = name.to_s.singularize.capitalize

    options.each do |k, v|
      instance_variable_set("@#{k.to_s}", v)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    class_name = self_class_name.to_s.singularize.underscore.camelcase.downcase
    @foreign_key = "#{class_name}_id".to_sym
    @primary_key = "id".to_sym
    @class_name = name.to_s.singularize.capitalize

    options.each do |k, v|
      instance_variable_set("@#{k.to_s}", v)
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    options = self.assoc_options[name]

    define_method(name) do
      f_key = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => f_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options.model_class.where(options.foreign_key => self.send(options.primary_key))
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end

  def has_one_through(name, through_name, source_name)
    debugger
    define_method(name) do
      debugger
      through_query(through_name, source_name).first
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_query(through_name, source_name)
    end
  end

  private

  def through_query(through_name, source_name)
    through_options = self.class.assoc_options[through_name]
    source_options = through_options.model_class.assoc_options[source_name.to_sym]

    through_table = through_options.table_name
    source_table = source_options.table_name

    source_fkey = source_options.foreign_key
    source_pkey = source_options.primary_key

    through_pkey = through_options.primary_key
    through_fkey_val = self.send(through_options.foreign_key).to_s

    query = DBConnection.execute(<<-SQL,)
      SELECT #{source_table}.*
      FROM #{through_table}
      JOIN #{source_table}
      ON #{through_table}.#{source_fkey} = #{source_table}.#{source_pkey}
      WHERE #{through_table}.#{through_pkey} = #{through_fkey_val}
    SQL

    source_options.model_class.parse_all(query)
  end
end

class SQLObject
  extend Associatable
  include Associatable
end
