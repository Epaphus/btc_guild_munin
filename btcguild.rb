#!/usr/bin/env /usr/local/bin/ruby
require 'json'
require "net/https"
require "uri"

apikey = ENV.member?('apikey') ? ENV['apikey']: "notset"
statedir = ENV.member?('MUNIN_PLUGSTATE') ? ENV['MUNIN_PLUGSTATE']: "/var/lib/munin-node/plugin-state"
statefile = "#{statedir}/btcguild_#{apikey}"

# Bomb out of if the API hasn't been set
if apikey == "notset"
    puts "API key not set, Please set API Key in your Munin config"
    exit 1
end

# API request
def getrequest(apikey)
  begin
      uri = URI.parse("https://www.btcguild.com/api.php?api_key=#{apikey}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      httpdata = http.request(request)
      return httpdata.body
  end rescue begin
      puts "Problem with API request"
      exit 1   
  end 
end

# Check to see if state file exists and read from it if it is less than 30 secs old
# otherwise get data from the BTC Guild API
if File.exists?(statefile)
  if (File.mtime(statefile) < Time.now - 30)
    response = getrequest(apikey)
  else
    response = File.read(statefile)
  end
else
  response = getrequest(apikey)
end

# BTC Guild API has a rate limit, if we this then read from cached file.
if response == "You have made too many API requests recently. API calls are limited to once every 15 seconds."
  puts "too many API requests"
  puts response
  puts ""
  if File.exists?(statefile)
    response = File.read(statefile)
  else
    puts "Too many API requests and no cached data, unable to continue"
    exit 1
  end
  
end

# Make sure we can parse the data before we continue
if parsed = JSON.parse(response) then
  file = File.open(statefile, "w")
  file.write(response)
  file.close 
else
  puts "Unable to get parsable data from API or Cache"
  exit 1
end



# output Munin graph config if requested
if ARGV[0] == "config"
  puts "multigraph pool_speed
graph_title Pool performance
graph_category BTC
graph_vlabel Hashes per second
graph_args --base 1000
pool_speed.draw AREASTACK
pool_speed.label Pool Speed
pool_speed.type GAUGE
  
multigraph earnings
graph_title Earnings
graph_category BTC
graph_vlabel Bitcoins earned
total_rewards.draw LINE1
total_rewards.label Total Rewards
total_rewards.type GAUGE
paid_rewards.draw LINE1
paid_rewards.label Paid Rewards
paid_rewards.type GAUGE
past_24h_rewards.draw LINE1
past_24h_rewards.label Past 24h Rewards
past_24h_rewards.type GAUGE
unpaid_rewards.draw LINE1
unpaid_rewards.label Unpaid Rewards
unpaid_rewards.type GAUGE
  
multigraph worker_hashrate
graph_title Worker Hashrate
graph_category BTC
graph_vlabel Hashes per second"
count = 1
parsed["workers"].each do |worker|
  puts "#{worker[count]["worker_name"]}_hashrate.type GAUGE"
  puts "#{worker[count]["worker_name"]}_hashrate.draw LINE1"
  puts "#{worker[count]["worker_name"]}_hashrate.label #{worker[count]["worker_name"]} Hash Rate"
  puts "#{worker[count]["worker_name"]}_validshare.type COUNTER"
  puts "#{worker[count]["worker_name"]}_validshare.draw LINE1"
  puts "#{worker[count]["worker_name"]}_validshare.label #{worker[count]["worker_name"]} Valid Shares"
  puts "#{worker[count]["worker_name"]}_staleshare.type COUNTER"
  puts "#{worker[count]["worker_name"]}_staleshare.draw LINE1"
  puts "#{worker[count]["worker_name"]}_staleshare.label #{worker[count]["worker_name"]} Stale Shares"
  puts "#{worker[count]["worker_name"]}_dupeshare.type COUNTER"
  puts "#{worker[count]["worker_name"]}_dupeshare.draw LINE1"
  puts "#{worker[count]["worker_name"]}_dupeshare.label #{worker[count]["worker_name"]} Dupe Shares"
  puts "#{worker[count]["worker_name"]}_unknownshare.type COUNTER"
  puts "#{worker[count]["worker_name"]}_unknownshare.draw LINE1"
  puts "#{worker[count]["worker_name"]}_unknownshare.label #{worker[count]["worker_name"]} Unknown Shares"
end

count = 1
parsed["workers"].each do |worker|
  puts "multigraph worker_hashrate.#{worker[count]["worker_name"]}"
  puts "graph_title Worker - #{worker[count]["worker_name"]}"
  puts "graph_category BTC"
  puts "graph_vlabel Hashes per second"
  puts "graph_args --base 1000"
  puts "hashrate.type GAUGE"
  puts "hashrate.draw LINE1"
  puts "hashrate.label Hash Rate"
  puts "validshare.type COUNTER"
  puts "validshare.draw LINE1"
  puts "validshare.label Valid Shares"
  puts "staleshare.type COUNTER"
  puts "staleshare.draw LINE1"
  puts "staleshare.label Stale Shares"
  puts "dupeshare.type COUNTER"
  puts "dupeshare.draw LINE1"
  puts "dupeshare.label Dupe Shares"
  puts "unknownshare.type COUNTER"
  puts "unknownshare.draw LINE1"
  puts "unknownshare.label Unknown Shares"
  puts
end



exit  
end

#output graph data
puts "multigraph pool_speed
pool_speed.value #{parsed["pool"]["pool_speed"]}

multigraph earnings
total_rewards.value #{parsed["user"]["total_rewards"]}
paid_rewards.value #{parsed["user"]["paid_rewards"]}
past_24h_rewards.value #{parsed["user"]["past_24h_rewards"]}
unpaid_rewards.value #{parsed["user"]["unpaid_rewards"]}"

puts "multigraph worker_hashrate"
count = 1
parsed["workers"].each do |worker|
  puts "#{worker[count]["worker_name"]}_hashrate.value #{worker[count]["hash_rate"]}"
  puts "#{worker[count]["worker_name"]}_validshare.value #{worker[count]["valid_shares"]}"
  puts "#{worker[count]["worker_name"]}_staleshare.value #{worker[count]["stale_shares"]}"
  puts "#{worker[count]["worker_name"]}_dupeshare.value #{worker[count]["dupe_shares"]}"
  puts "#{worker[count]["worker_name"]}_unknownshare.value #{worker[count]["unknown_shares"]}"
  
end
puts

count = 1
parsed["workers"].each do |worker|
  puts "multigraph worker_hashrate.#{worker[count]["worker_name"]}"
  puts "hashrate.value #{worker[count]["hash_rate"]}"
  puts "validshare.value #{worker[count]["valid_shares"]}"
  puts "staleshare.value #{worker[count]["stale_shares"]}"
  puts "dupeshare.value #{worker[count]["dupe_shares"]}"
  puts "unknownshare.value #{worker[count]["unknown_shares"]}"
  puts
    
end

