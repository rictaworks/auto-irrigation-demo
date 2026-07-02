class IrrigationLog < ApplicationRecord
  DECISIONS = %w[immediate recommended watch none].freeze

  belongs_to :session

  validates :decision, inclusion: { in: DECISIONS }
  validates :soil_moisture, :weather_coeff, :total_score, :recommended_l, numericality: true
  validates :action_taken, presence: true
  validates :executed_at, presence: true
end
