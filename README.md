BTC Guild Munin Plugin
============

This plugin gets stats from the BTC Guild API and graphs them in Munin. 
This will get the Pool speed, Bitcoins earned and worker stats. 


To use you will need your API key from the BTC Guild website and put the following in your Munin plugin config

	[btcguild]
	env.apikey yourkey


The plugin currently gets the following information

* Earnings
* BTC Guild Pool Speed
* Worker Hashrate per worker
* Share stats per worker (Valid, Dupe, Stale, Unknown)
 


