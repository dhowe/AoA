#!/usr/bin/perl

@files=("apartmant1.flv", "apartmant106.flv", "apartmant108.flv", "apartmant13.flv", "apartmant14.flv", "apartmant16.flv", "apartmant19.flv", "apartmant2.flv", "apartmant20.flv", "apartmant22.flv", "apartmant23.flv", "apartmant24.flv", "apartmant26.flv", "apartmant27.flv", "apartmant28.flv", "apartmant30.flv", "apartmant32.flv", "apartmant33.flv", "apartmant34.flv", "apartmant35.flv", "apartmant37.flv", "apartmant38.flv", "apartmant39.flv", "apartmant4.flv", "apartmant40.flv", "apartmant41.flv", "apartmant44.flv", "apartmant45.flv", "apartmant46.flv", "apartmant48.flv", "apartmant49.flv", "apartmant50.flv", "apartmant51.flv", "apartmant55.flv", "apartmant56.flv", "apartmant58.flv", "apartmant59.flv", "apartmant61.flv", "apartmant62.flv", "apartmant63.flv", "apartmant65.flv", "apartmant66.flv", "apartmant67.flv", "apartmant68.flv", "apartmant69.flv", "apartmant7.flv", "apartmant75.flv", "apartmant76.flv", "apartmant8.flv", "apartmant80.flv", "apartmant83.flv", "apartmant84.flv", "apartmant91.flv", "apartmant92.flv", "construction_1.flv", "construction_2.flv", "construction_3.flv", "construction_4.flv", "drive1.flv", "drive2.flv", "drive3.flv", "drive4.flv", "drive5.flv", "elevator1.flv", "elevator11.flv", "elevator12.flv", "elevator14.flv", "elevator15.flv", "elevator16.flv", "elevator18.flv", "elevator3.flv", "elevator4.flv", "elevator5.flv", "elevator6.flv", "elevator7.flv", "elevator8.flv", "light1.flv", "light2.flv", "street1.flv", "street11.flv", "street12.flv", "street16.flv", "street2.flv", "street3.flv", "street4.flv", "street5.flv", "street6.flv", "street9.flv", "transit_transfer_1.flv", "transit_transfer_10.flv", "transit_transfer_2.flv", "transit_transfer_3.flv", "transit_transfer_4.flv", "transit_transfer_5.flv", "transit_transfer_6.flv", "transit_transfer_8.flv", "transit_transfer_9.flv", "water1.flv", "water10.flv", "water11.flv", "water2.flv", "water3.flv", "water4.flv", "water5.flv", "water6.flv", "water7.flv", "water8.flv", "water9.flv");

foreach $f (@files) {
  $i++;
	#print "$f.flv\n";
	print "cp $f.flv good\n";
	#`cp $f.flv good`;
}
#print "$i files\n";


