class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # 全モデル共通のロジックを追加する場合はここに記述
end
