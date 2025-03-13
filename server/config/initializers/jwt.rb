JWT_SECRET = ENV.fetch("JWT_SECRET") do
  raise "Falta la variable de entorno JWT_SECRET en el entorno #{Rails.env}"
end
