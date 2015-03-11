#!/usr/bin/perl

$text = "#!/usr/bin/perl\n\n";
#$text .= "\@files = \`ls *.flv\`;
$text .= '(';

@files = `ls *.flv`;
foreach $f (@files) {
  chomp $f;
  $text .= "\"$f\", ";
}
$text .= ');';
print $text;
#open (OUT, '>>clip-list.txt');
#print OUT "$text\n";
#close (OUT);
