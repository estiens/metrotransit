require "rest-client"
require 'json'
require 'dstk'
require 'debugger'

dstk = DSTK::DSTK.new
API_URL="http://metrotransitapi.appspot.com/"

routes_array=[]

JSON.parse(RestClient.get API_URL+"routes").each do |routes|
  routes_array<<routes
end

routes_array.each do |route|
  puts "stops for #{route["name"]}"
  begin
    routedata=RestClient.get API_URL+"/stops?route="+route["number"]+"&direction=1"
  rescue
    routedata=RestClient.get API_URL+"/stops?route="+route["number"]+"&direction=3"
  end
  stops = JSON.parse(routedata)
  stops.each do |stop|
    name=stop["name"]
    geocode = dstk.geocode(name + " Minneapolis, MN")
    begin
      lat=geocode["results"].first["geometry"]["location"]["lat"]
      lng=geocode["results"].first["geometry"]["location"]["lng"]
      statistics= dstk.coordinates2statistics([lat, lng], 'us_population_poverty')
      poverty_perc=statistics[0]["statistics"]["us_population_poverty"]["value"]
      puts "% of residents living below poverty line near #{stop["name"]}: #{poverty_perc*100}"
      rescue
        puts "no data found"
    end
  end
end

# addresses=["6th St SE and E Hennepin Ave", "E Hennepin Ave and 8th St SE", "Jones Hall and Eddy Hall (U of M)", "Franklin Avenue Station", "Franklin Ave and Chicago Ave"]
 
# addresses.each do |address|
# geocode = dstk.geocode(address)
# begin
# lat=geocode["results"].first["geometry"]["location"]["lat"]
# lng=geocode["results"].first["geometry"]["location"]["lng"]
# puts lat 
# puts lng
# statistics= dstk.coordinates2statistics([lat, lng], 'population_density')
# population_density=statistics[0]["statistics"]["population_density"]["value"]
# puts population_density
# rescue
#   puts "no data found"
# end

# # routes_array.each do |route|
# #   puts route["name"]
# #   puts route["number"]
# end


#   end
# end
# #     debugger
# #     #geocode = dstk.geocode(stop[name]+" Minneapolis, MN")
