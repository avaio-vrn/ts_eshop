module TsEshop
  class Engine < Rails::Engine
    engine_name 'ts_eshop'

    config.before_initialize do
      config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
    end
  end
end
