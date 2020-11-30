defmodule Parking.Geolocation do

  def find_location(address) do
    splited = String.split(address, ",")
    #IO.inspect splited
    addressLine = Enum.at(splited,0)
    postalCode = Enum.at(splited,1)
    uri = "http://dev.virtualearth.net/REST/v1/Locations/EE/Tartu%20maakond/#{URI.encode(addressLine)}?includeNeighborhood=false&key=#{get_key()}"
    # uri = "http://dev.virtualearth.net/REST/v1/Locations?q=1#{URI.encode(address)}%&key=#{get_key()}"
    IO.inspect uri
    response = HTTPoison.get! uri
    #IO.inspect response.body
    matches = Regex.named_captures(~r/coordinates\D+(?<lat>-?\d+.\d+)\D+(?<long>-?\d+.\d+)/, response.body)
    [{v1, _}, {v2, _}] = [matches["lat"] |> Float.parse, matches["long"] |> Float.parse]
    [v1, v2]
  end

  def distance(origin, destination) do


    [o1, o2] = find_location(origin)
    [manual_distance(o1,o2,destination),0.0]

 end
  #uri = "http://dev.virtualearth.net/REST/V1/Routes/Walking?wp.0=#{o1},#{o2}&wp.1=#{d1},#{d2}&key=#{get_key()}"

 """

 [o1, o2] = find_location(origin)
 [d1, d2] = find_location(destination)
 response = HTTPoison.get! uri
 matches = Regex.named_captures(~r/travelD\D+(?<dist>\d+.\d+)\D+(?<dur>\d+.\d+)/,response.body)
 [{v1, _}, {v2, _}] = [matches["dist"] |> Float.parse, matches["dur"] |> Float.parse]
 [v1, v2]
 """
 def distance(o1,o2,destination) do
  [d1, d2] = find_location(destination)
  #uri = "https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix?origins=#{o1},#{o2}&destinations=#{d1},#{d2}&travelMode=walking&key=#{get_key()}"
    uri = "http://dev.virtualearth.net/REST/V1/Routes/Walking?wp.0=#{o1},#{o2}&wp.1=#{d1},#{d2}&key=#{get_key()}"

    response = HTTPoison.get! uri
    #IO.puts response.body
    matches = Regex.named_captures(~r/travelD\D+(?<dist>\d+.\d+)\D+(?<dur>\d+.\d+)/,response.body)
    [{v1, _}, {v2, _}] = [matches["dist"] |> Float.parse, matches["dur"] |> Float.parse]
    [v1, v2]
 end



    def manual_distance(o1,o2,dest) do
      [d1, d2] = find_location(dest)
      IO.puts "Destination"
      IO.inspect d1
      IO.inspect d2
      find_distance(o1, o2,d1,d2)

    end

    def find_distance(o1,o2,d1,d2) do
     # IO.puts Distance.GreatCircle.distance({o1,o2},{d1 ,d2})/1000
     # IO.puts Distance.GreatCircle.distance({o1,o2},{d1 ,d2})

      (Distance.GreatCircle.distance({o1,o2},{d1 ,d2}))/1000
    end


  defp get_key(), do: "AkyVX82EFOLKSZ46JDAiHsMAE9IBq6sN_MHOZRasAanfS5qfZm6yhUvFmXCfhZG_"
end
