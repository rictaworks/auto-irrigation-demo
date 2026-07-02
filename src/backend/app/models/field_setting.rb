class FieldSetting < ApplicationRecord
  SOIL_TYPES = %w[sandy_loam loam clay].freeze

  belongs_to :session

  validates :area_m2, numericality: { greater_than: 0 }
  validates :soil_type, inclusion: { in: SOIL_TYPES }
end
