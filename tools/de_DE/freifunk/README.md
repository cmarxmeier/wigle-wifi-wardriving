nodes.json Files are generated for Freifunk Map-Servers and contain
all precise information about Routers that provide free wifi Access in Germany 

For more info see www.freifunk.net

Channels may differ between the different Freifunk communities. Get Community nodes.json file from Mapserver, check for Wifi Channel config in Community github/site.conf and generate:

#"./generate_wigle_scan_v2.pl nodes-v2-filename Wifi-Channel" 

  or for old v1-format:

#"./generate_wigle_scan_v1.pl nodes-v1-filename Wifi-Channel"
 
 
cause we have router's exact position, we can assume -45 RSSI and 0 AccuracyMeters  

The example data was taken from Map-Server https://map.freifunk-rhein-sieg.net
and is generated every 10 minutes under 
https://map.freifunk-rhein-sieg.net/data/mobilemeshviewer/nodes_v1.json
for use with an Android Monitoring App.
