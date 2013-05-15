#!/usr/bin/env /usr/local/bin/ruby
require 'json'

# BTC Guild limits API calls, due to the way Munin works this means we can get the config but then get an API error when it goes to get the data
# To get around this for now I have setup a cron job which downloads the json output from the API every 5 mins
# This script then reads that file, I plan to handle this within the script shortly
#
# Cron tab has the following
# */5 * * * * wget "https://www.btcguild.com/api.php?api_key=[APIKEY]" -O /tmp/btc.json &> /dev/null
#
#
 
# Set /tmp/btc.json to path where you have put the BTC guild API output
response = File.read("/tmp/btc.json")
parsed = JSON.parse(response)




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
  puts "#{worker[count]["worker_name"]}_hashrate.type COUNTER"
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
  puts "hashrate.type COUNTER"
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

