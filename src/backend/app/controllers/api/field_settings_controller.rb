module Api
  class FieldSettingsController < BaseController
    def create
      check_honeypot!

      setting = current_session.field_settings.create!(field_setting_params)
      render json: serialize(setting), status: :created
    end

    private

    def field_setting_params
      params.require(:field_setting).permit(:area_m2, :soil_type)
    end

    def serialize(setting)
      {
        id: setting.id,
        area_m2: setting.area_m2,
        soil_type: setting.soil_type
      }
    end
  end
end
