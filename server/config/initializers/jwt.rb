JWT_SECRET = ENV.fetch("JWT_SECRET") do
  raise "The enviroment variable JWT_SECRET is missing in: #{Rails.env}"
end
