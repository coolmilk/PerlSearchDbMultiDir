use strict;
use warnings;

my $filename = $ARGV[0];
my %hash_id_date;
my $output_dir="glog";

sub BuildAbsPathList {
  my $fn=shift;
  my @l_ret_path_list;
  my $find_result= `find ./ -name "$fn"`;
  my @l_path_list=split('\n', $find_result);
  my $size=@l_path_list;
  my %hash_path_id_date;
  for(my $i=0;$i<$size;$i++) {
    my @l_fields=split('/', $l_path_list[$i]); #git id locates $l_fields[3]
    $hash_path_id_date{$l_path_list[$i]}=$hash_id_date{$l_fields[3]};
  }

  #print "@l_path_list\n";
  #print "@{[%hash_path_id_date]}\n";
  foreach my $key (sort { $hash_path_id_date{$a} <=> $hash_path_id_date{$b} } keys %hash_path_id_date) {
    push @l_ret_path_list, $key;
  }
  #print "$size\n abs_list:\n@abs_path_list\n";
  return @l_ret_path_list;
}

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
    #my $find_result= `find ./ -name "$fields[1].txt"`;
    #@abs_path_list=split('\n', $find_result);
    my @abs_path_list=BuildAbsPathList("$fields[1].txt");
    my $abs_path_list_cnt=@abs_path_list;
    my $dst_fh;
    my $last_record_pnp="XD";
    for(my $i=0;$i<$abs_path_list_cnt;$i++) {
      my $abs_path=$abs_path_list[$i];
      my $abs_dst="$output_dir/$fields[1]__$fields[2]__$fields[3].log";
      print "search in $abs_path\n";
      if(open(my $db_fh, $abs_path)) {
        my $match_flag = 0;
        my $str_a=$fields[2].$fields[3].$fields[4];
        my $str_b="XD";
        open($dst_fh, '>>', $abs_dst);
        while (my $db_row = <$db_fh>) {
          my @db_fields = split('\t', $db_row);
          #$fields[2] $fields[3] $fields[4] compare to $db_fields[0] $db_fields[1] $db_fields[2]          
          my $db_fields_size=@db_fields;
          if($db_fields_size>=3) {
            $str_b=$db_fields[0].$db_fields[1].$db_fields[2];
            if($str_a eq $str_b) {
              $match_flag=1; #test case failed
              last;
            }
          }
        } # end of while
        
        my @split_abs_path=split('/', $abs_path); #git id locates $split_abs_path[3]
        if($match_flag==0) {
          if(($last_record_pnp ne "passed on")) {
            if(exists($hash_id_date{$split_abs_path[3]})) {            
              print $dst_fh "$row\tpassed on\t$hash_id_date{$split_abs_path[3]}\t$split_abs_path[3]\n"; #new col9&10 added
              print "$row\tpassed on\t$hash_id_date{$split_abs_path[3]}\t$split_abs_path[3]\n";
            }
            else {
              print $dst_fh "$row\tpassed on\t$split_abs_path[3]\n";
            }
          }
          else {
            print "passed again\n";
          }
          $last_record_pnp="passed on";
        }
        else { #match
          if(($last_record_pnp ne "failed on")) {
            if(exists($hash_id_date{$split_abs_path[3]})) {         
              print $dst_fh "$row\tfailed on\t$hash_id_date{$split_abs_path[3]}\t$split_abs_path[3]\n"; #new col9&10 added
              print "$row\tfailed on\t$hash_id_date{$split_abs_path[3]}\t$split_abs_path[3]\n";
            }
            else {
              print $dst_fh "$row\tfailed on\t$split_abs_path[3]\n";
            }
          }
          else {
            print "failed again\n";
          }
          $last_record_pnp="failed on";
        }
        close($dst_fh);
      } #end of if
    } #end of for
  } #end of else
} #end of while
