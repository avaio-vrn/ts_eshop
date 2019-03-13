BREADCRUMBS =
      if File.exists?(Rails.root.join('config/breadcrumbs.yml'))
        YAML.load(File.open(Rails.root.join('config/breadcrumbs.yml')))
      else
        []
      end
