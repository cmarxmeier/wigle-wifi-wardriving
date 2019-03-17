#!/usr/bin/perl
use strict;
use JSON;
use POSIX qw(strftime);

my $node_json_file = $ARGV[0];
my $channel = $ARGV[1];

my $nodecounter = 0;
my $maxrecords = 0;
# Timestamp Format 2019-02-15T02:22:16+0100
my $date = strftime "%Y%m%d", localtime;
my $wigledate = strftime "%Y-%m-%d", localtime;
my $time = strftime "%H%M%S", localtime;
my $wigletime = strftime "%H:%M:%S", localtime;
my $timestamp = $date.$time;
my $wigletimestamp = $wigledate." ".$wigletime;
my $wiglewifi_scan_file = "/opt/data/mobilemeshviewer/WigleWifi_".$timestamp.".csv";


if (( ! $node_json_file ) || ( ! $channel)){
                print "USAGE: ./generate_wigle_scan_v1.pl <in_nodes_v1_filename> <Wifi-Channel>\n";
                exit 0;
        }


main();

sub main {
        my $node_json = &get_node_json();
        for my $node(keys %{$node_json->{'nodes'}}) {
          $maxrecords++;
        }
        open(my $wa, '>', $wiglewifi_scan_file) || die $!;
        # Print dummy device header
        print $wa "WigleWifi-1.4,appRelease=2.42,model=Freifunk,release=8.1.0,device=dummy,display=OPM8.190305.001-myself5\@M5TR,board=MSM8974,brand=Freifunk\n";
        print $wa "MAC,SSID,AuthMode,FirstSeen,Channel,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,Type\n";

        # print "Records: ".$maxrecords;
        for my $node(keys %{$node_json->{'nodes'}}) {
           if ( $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0] ) {
                # mesh0 mac is not, what we want - lets substract 1 to get wifi ap interface mac
                my $mac = $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0];
                my $mac_prefix = substr($mac,0,15);
                my $mac_end = substr($mac,15,2);
                my $mac_calc = hex($mac_end);
                my $mac_int  = int($mac_calc);
                $mac_int --;
                my $mac_new = sprintf("%x", $mac_int);
                if ( length($mac_new) < 2) {
                   $mac_new = "0".$mac_new;
                }
             my $maccombined = $mac_prefix.$mac_new;
             my $latitude = $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'location'}->{'latitude'};
             my $longitude = $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'location'}->{'longitude'};
             my $lenmac = length($maccombined);
             my $lenlat = length ($latitude);
             my $lenlng = length($longitude);
             if ( $lenmac > 12){
                 if ( $lenlat > 3){
                    if ( $lenlng > 3){
                      print $wa $mac_prefix.$mac_new.",Freifunk,[ESS],".$wigletimestamp.",".$channel.",-45,".$latitude.",".$longitude.",0,0,WIFI\n";
                    }
                 }
             }
           }
           $nodecounter++;
        }
}

sub write_json {
        my($json) = @_;

        open(my $fh, '>', $node_json_file) || die $!;
        print $fh to_json($json);
        close($fh);
}

sub get_node_json {
        open(my $fh, '<', $node_json_file) || die $!;
        my $json_data = join('',<$fh>);
        close($fh);

        return from_json($json_data);
}


