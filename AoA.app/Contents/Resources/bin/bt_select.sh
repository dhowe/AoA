#!/usr/bin/perl

@files=("buddhist_temple_100-1.flv", "buddhist_temple_100-2.flv", "buddhist_temple_109.flv", "buddhist_temple_113.flv", "buddhist_temple_128.flv", "buddhist_temple_149.flv", "buddhist_temple_167.flv", "buddhist_temple_17.flv", "buddhist_temple_22.flv", "buddhist_temple_25.flv", "buddhist_temple_28.flv", "buddhist_temple_42.flv", "buddhist_temple_70.flv", "buddhist_temple_167.flv", "buddhist_temple_78.flv", "buddhist_temple_86.flv");


foreach $f (@files) {
	print "mv $f good-bt\n";
	`mv $f good-bt/`;
}

#for ($i = 0;$i < 170; $i++) {
#  $file = "buddhist_temple_$i.flv";
#  if ( -e $file) {
#		print "mv $file good-bt\n";
#	  `mv $file good-bt/`;
#  }
#}
