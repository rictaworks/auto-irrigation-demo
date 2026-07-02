# ハニーポット方式によるBot送信チェック。
# 隠しフィールドに値が入っていれば人間ではなくBotによる送信とみなす。
class HoneypotChecker
  Result = Struct.new(:is_bot, keyword_init: true)

  def initialize(field_name: HoneypotConfig.load.fetch(:field_name))
    @field_name = field_name.to_s
  end

  def check(form_data)
    value = form_data[@field_name] || form_data[@field_name.to_sym]
    Result.new(is_bot: value.present?)
  end
end
