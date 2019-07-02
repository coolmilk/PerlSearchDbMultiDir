use strict;
use warnings;

my $filename = $ARGV[0];
our @abs_path_list;
our $abs_path_list_cnt=0;
our %hash_id_date;
our $output_dir="glog";
my $dst_fh;
our $last_record_date=0;
our $last_record_pnp=0;

open(my $fh, $filename)
  or die "Could not open file '$filename' $!";

#build hash list commit id and date
if(open(my $t_fh, "cmt_id_date.txt")) {
  while (my $row = <$t_fh>) {
    my @fields = split('\t', $row);
    my $ar_size = @fields;
    if($ar_size==2) {
      chomp $fields[1];
      $hash_id_date{$fields[0]}=$fields[1];
    }
  }
  close($t_fh);
}

#set and check ouput directory
if(-e $output_dir) {
  $output_dir="./$output_dir";
}
else {
  mkdir $output_dir, 0777;
  $output_dir="./$output_dir";
}

#main process starts
while (my $row = <$fh>) {
  
  chomp $row;
  my @fields = split('\t', $row);
  #$line_cnt++;
  my $ar_size = @fields;

  if($ar_size > 8) {
    #print "$line_cnt $ar_size cols, line skipped\n";
  }
  elsif($ar_size < 8) {
    #print "$line_cnt $ar_size cols, line skipped\n";
  }
  else { # line with correct format
    my $find_result= `find ./ -name "$fields[1].txt"`;
    @abs_path_list=split('\n', $find_result);
    $abs_path_list_cnt=@abs_path_list;

    for(my $i=0;$i<$abs_path_list_cnt;$i++) {
      my $abs_path=$abs_path_list[$i];
      my $abs_dst="$output_dir/$fields[1]__$fields[2]__$fields[3].log";
      print "$abs_path\n";
#      if(open(my $db_fh, $abs_path)) {
#        my $match_flag = 0;
#        my $str_a=$fields[2].$fields[3].$fields[4];
#        open($dst_fh, "+>> $abs_dst");
#        while (my $db_row = <$db_fh>) {
#          my @db_fields = split('\t', $db_row);
          #$fields[2] $fields[3] $fields[4] compare to $db_fields[0] $db_fields[1] $db_fields[2]          
#          my $str_b=$db_fields[0].$db_fields[1].$db_fields[2];

#          if($str_a eq $str_b) {
#            $match_flag=1;             
#            last;
#          }
#          close($db_fh);
#        } # end of while
        
        my @split_abs_path=split('/', $abs_path); #git id locates $split_abs_path[2]
        print "$split_abs_path[2]  $hash_id_date{$split_abs_path[2]}\n";
#        if($match_flag==0) {
#          if(($last_record_pnp ne "passed on") || ($last_record_date==0)) {
#            print $dst_fh "$row\tpassed on\t$hash_id_date{$split_abs_path[2]}\n"; #new col9&10 added
#            $last_record_pnp="passed on";
#            $last_record_date=$hash_id_date{$split_abs_path[2]};
#          }
#        }
#        else {
#          if(($last_record_pnp ne "failed on") || ($last_record_date==0)) {
#            print $dst_fh "$row\tfailed on\t$hash_id_date{$split_abs_path[2]}\n"; #new col9&10 added
#            $last_record_pnp="failed on";
#            $last_record_date=$hash_id_date{$split_abs_path[2]};
#          }
#        }
#        close($dst_fh);
#      } #end of if
    } #end of for
  } #end of else
} #end of while
