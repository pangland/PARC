require_relative '../lib_post/sql_object'
require_relative '../lib_post/db_connection'
require 'sqlite3'
require 'byebug'

DBConnection.reset

class Style < SQLObject
  has_many :practitioners
  has_many :signaturetechniques
  # has_one_through 'signaturetechnique', 'style', 'signaturetechnique'
  belongs_to :founder, class_name: 'Practitioner', foreign_key: :founder_id
  self.finalize!
end

class Practitioner < SQLObject
  belongs_to :style
  has_many :signaturetechniques
  has_one_through 'founder', 'style', 'practitioner'
  self.finalize!
end

class Signaturetechnique < SQLObject
  belongs_to :style, foreign_key: :style_id
  self.finalize!
end
