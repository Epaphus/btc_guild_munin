BTC Guild Munin Plugin
============

This plugin gets stats from the BTC Guild API and graphs them in Munin. 



To use you will need your API key from the BTC Guild website and put the following in your Munin plugin config

	[btcguild]
	env.apikey yourkey
	timeout 40


The plugin currently gets the following information

* Earnings
* BTC Guild Pool Speed
* Worker Hashrate per worker
* Share stats per worker (Valid, Dupe, Stale, Unknown)
 

2013-05-23: Added a timeout to the munin-node config and in plugin as sometimes the BTC guild website takes longer than the default timeout which caused gaps in the graph.

