#!/usr/bin/perl

use strict;
use warnings;
use JSON::Parse 'json_file_to_perl';
#use Data::Dumper;
use Data::Dumper qw(Dumper);
use DateTime;
use strict;
use JSON;
use POSIX qw(strftime);


# define default runtime vars
my $filename = $ARGV[0];
my $channel = $ARGV[1];
# Timestamp Format 2019-02-15T02:22:16+0100
my $date = strftime "%Y%m%d", localtime;
my $wigledate = strftime "%Y-%m-%d", localtime;
my $time = strftime "%H%M%S", localtime;
my $wigletime = strftime "%H:%M:%S", localtime;
my $timestamp = $date.$time;
my $wigletimestamp = $wigledate." ".$wigletime;
my $destfilename = "/opt/data/mobilemeshviewer/WigleWifi_".$timestamp.".csv";
my $nodecounter_max = 0;
my $nodecounter = 0;
my $nodesfound = 0;
my $created_on;
# my $filename = "nodes.json";

if (( ! $filename ) || ( ! $channel)){
                print "USAGE: ./generate_wigle_scan_v2.pl <in_nodes_v2_filename> <Wifi-Channel>\n";
	        exit 0;        
	}

# test, if file exist
if ( -f $filename ){

	# Read JSON data from FILE
	my $content = json_file_to_perl ($filename);

	 # print ref $content, "\n";

	foreach my $key ( keys %$content ) {
	   # print $key, " => ", $content->{$key},"\n";
              if ( $key eq 'nodes' ){
	                   $nodesfound=1; 
		#	foreach my @node 
                     
               } # if key nodes         


	} # foreach keys

        if ( $nodesfound ) {
	        print "found nodes array...\n"; 

	        open(my $wa, '>', $destfilename) || die $!;

		while ( $content->{'nodes'}->[$nodecounter_max] ){
                   # just count to max values
                   # print $nodecounter_max.": ".$content->{'nodes'}->[$nodecounter_max]->{'nodeinfo'}->{'node_id'}."\n";
                   $nodecounter_max++;
                }
	        $nodecounter_max --;
                print "Records: ".$nodecounter_max."\n";	

                 # Print dummy device header
                 print $wa "WigleWifi-1.4,appRelease=2.42,model=Freifunk,release=8.1.0,device=dummy,display=OPM8.190305.001-myself5\@M5TR,board=MSM8974,brand=Freifunk\n";
                 print $wa "MAC,SSID,AuthMode,FirstSeen,Channel,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,Type\n";



                # Process array for each of nodecounter-max nodes:
                for (my $i = 0; $i < $nodecounter_max; $i++){
		   my $mac_found = 0;
                   my $location_found = 0;  
                   my $latitude_found = 0;
                   my $longitude_found = 0;
                   my $latitude = 0;
                   my $longitude = 0;
                   my $altitude = 0;
                   my $mac_new = "";
                   my $mac_prefix = "";



                   if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0] ){ 
		        # mesh0 mac is not, what we want - lets substract 1 to get wifi ap interface mac
		        my $mac = $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0];
                        $mac_prefix = substr($mac,0,15);
                        my $mac_end = substr($mac,15,2);
                        my $mac_calc = hex($mac_end);
                        my $mac_int  = int($mac_calc);
                        $mac_int --;
                        $mac_new = sprintf("%x", $mac_int);
                        if ( length($mac_new) < 2) {
                            $mac_new = "0".$mac_new;
                        }
                        $mac_found = 1;                  
                     }
	    	     if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}  ) {
	    	        if ($content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'longitude'}){
                             $longitude =$content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'longitude'};
		             $longitude_found = 1;	
                        }
                        if ($content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'latitude'}){
                           $latitude = $content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'latitude'};
			   $latitude_found = 1;
                        }
                        if  ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'altitude'}  ) {
			    $altitude = $content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'altitude'}; 
                        } else {
		           $altitude = 0; 
                        }
                        $location_found = 1;
                     }
	             # check needed values
                         if ( $mac_found ){
                            if ( $location_found ){
                              if ( $latitude_found ){ 
                                if ( $longitude_found ){ 
                                    print $wa $mac_prefix.$mac_new.",Freifunk,[ESS],".$wigletimestamp.",".$channel.",-45,".$latitude.",".$longitude.",".$altitude.",0,WIFI\n";
                                } 
			      }
                            }
                         }
                 
             	    $nodecounter ++;
                }
		close ($wa);        
         }
} else {
			print "ERROR: file ".$filename." does not exist.\n";
}


exit 0;




