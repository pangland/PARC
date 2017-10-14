require_relative '../lib_post/sql_object'
require_relative '../lib_post/db_connection'
require 'sqlite3'
require 'byebug'

DBConnection.reset

class Style < SQLObject
  has_many :practitioners
  has_one_through :signature_technique, :practitioner, :signature_techniques
  self.finalize!
end

class Practitioner < SQLObject
  belongs_to :style
  has_many :signature_techniques
  self.finalize!
end

class SignatureTechnique < SQLObject
  belongs_to :practitioner, foreign_key: :owner_id
  self.finalize!
end