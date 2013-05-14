BTC Guild Munin Plugin
============

This plugin gets stats from the BTC Guild API and graphs them in Munin.
This will get the Pool speed, Bitcoins earned and worker stats


BTC Guild limits API calls, due to the way Munin works this means we can get the config but then get an API error when it goes to get the data
To get around this for now I have setup a cron job which downloads the json output from the API every 5 mins
This script then reads that file, I plan to handle this within the script shortly

Cron tab has the following (replace [APIKEY] with your API key)

	*/5 * * * * wget "https://www.btcguild.com/api.php?api_key=[APIKEY]" -O /tmp/btc.json &> /dev/null



