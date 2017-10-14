require_relative '../lib_post/sql_object'
require_relative '../lib_post/db_connection'
require 'sqlite3'
require 'byebug'

DBConnection.reset

class Style < SQLObject
  has_many :practitioners
  has_one_through :signaturetechnique, :practitioner, :signaturetechnique
  self.finalize!
end

class Practitioner < SQLObject
  belongs_to :style
  has_many :signaturetechniques
  self.finalize!
end

class Signaturetechnique < SQLObject
  belongs_to :practitioner, foreign_key: :practitioner_id
  self.finalize!
end
