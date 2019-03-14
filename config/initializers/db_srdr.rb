DB_SRDR = YAML::load(ERB.new(File.read(Rails.root.join("config","database_srdr.yml"))).result)[Rails.env]
