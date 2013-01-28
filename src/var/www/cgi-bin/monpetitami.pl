#!/usr/bin/perl -w

use strict;
use CGI qw(:standard :cgi-lib );
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Data::Dumper;
use RRDs;
$|++;



# Get params
#EXAMPLE: ?m=load_one&r=hour&s=descending&c=Generic&h=pbs02.pic.es&sh=1&hc=4&z=small

my $params=Vars;
my $dibujo;
my $ganglia_path="/var/lib/ganglia/rrds/$params->{c}/$params->{h}";
my $dates={ 'hour' => '1h' , 'day' => '1d' , 'week' => '7d', 'month' => '1M', 'year' => '1y'};

# 3 arrays: Job/group, Job/queue, Job/eff
my @rrd_job_grp =("-","--imgformat=PNG","--width=600","--height=150","-u15","-l0","--start","-$dates->{$params->{r}}","--end=now");
my @rrd_job_queue=("-","--imgformat=PNG","--width=600","--height=150","-u15","-l0","--start","-$dates->{$params->{r}}","--end=now");
my @job_by_eff=("-","--imgformat=PNG","--width=600","--height=150","-u15","-l0","--start","-$dates->{$params->{r}}","--end=now");
my @maui_share=("-","--imgformat=PNG","--width=600","--height=150","-u15","-l0","--start","-$dates->{$params->{r}}","--end=now");
my @eff_colors =('#FF0000' , '#FE9A2E' , '#04B404');
my @maui_colors =('#FF00FF','#0B610B', "#00DD00","#0000FF","#DD9900", "#BB55BB","#00DDDD","#0055DD", "#FFFF00","#9900DD","#99DD00", "#00DD99","#0099DD","#DD0000", "#FF9988","#00DD44","#FF55FF", "#DD4400","#44DD00","#999999", "#DD2200","#442200","#992222");
#my @group_colors =('#FF00FF','#0B610B', "#00DD00","#0000FF","#DD9900", "#BB55BB","#00DDDD","#0055DD", "#FFFF00","#9900DD","#99DD00", "#00DD99","#0099DD","#DD0000", "#FF9988","#00DD44","#FF55FF", "#DD4400","#44DD00","#999999", "#DD2200","#442200","#992222","#F781F3","#F5A9A9");
my @group_colors =("#00DD00" ,"#0000FF" ,"#DD9900" ,"#BB55BB" ,"#00DDDD" ,"#0055DD" ,"#FFFF00" ,"#9900DD" ,"#99DD00" ,"#00DD99" ,"#0099DD" ,"#DD0000" ,"#99DD99" ,"#9999DD" ,"#DD9999" ,"#FF9988" ,"#00DD44" ,"#FF55FF" ,"#DD4400" ,"#44DD00" ,"#999999" ,"#AA44BB" ,"#CCDDDD" ,"#EE99FF" ,"#DD2200" ,"#442200" ,"#992222" ,"#229922" ,"#222299" ,"#992299");
my @queue_colors =('#0101DF','#04B404','#FE9A2E','#FFFF00','#DF01A5','#B40431','#0A0A2A','#F781F3','#F5A9A9','#A4A4A4');



# Find rrds and push them into each @
# Jobs_by_group_* Jobs_queued_by_queue_* Jobs_by_eff_* 

my @rrd_files=<$ganglia_path/*>;
my ($group_index, $queue_index, $eff_index,$maui_index)=(0,0,0,0);
foreach (@rrd_files) {
	if (/(Jobs_by_group_)(.*.)(.rrd)/) {
		create_rrd_line (\@rrd_job_grp, $_, $2, $group_colors[$group_index],"_Running_jobs");
		$group_index++;
	}
	if (/(Jobs_by_eff_)(.*.)(.rrd)/) {
		create_rrd_line (\@job_by_eff, $_, $2, $eff_colors[$eff_index],"_Eff_jobs");
		$eff_index++;
	}
	if (/(Jobs_queued_by_queue_)(.*.)(.rrd)/) {
		create_rrd_line (\@rrd_job_queue, $_, $2, $queue_colors[$queue_index],"_Queueed_jobs");
		$queue_index++;
	}
	if (/(FS_by_group_)(.*.)(.rrd)/) {
#		create_rrd_line (\@maui_share, $_, $2, $maui_colors[$maui_index],"_FS");
		create_rrd_line (\@maui_share, $_, $2, $group_colors[$maui_index],"_FS");
		$maui_index++;
	}
	
}	
		
#given("$params->{mode}") {
#	when (/maui/) {
#	}
#	when (/queue/) {
#		$dibujo=RRDs::graph(@rrd_job_queue);
#		my $ERR=RRDs::error;
#		die "ERROR while updating rrd file: $ERR\n" if $ERR;
#	}
#	when (/eff/) {
#		$dibujo=RRDs::graphv(@job_by_eff);
#		my $ERR=RRDs::error;
#		die "ERROR while updating rrd file: $ERR\n" if $ERR;
#	}
#	when (/torque/) {
#		$dibujo=RRDs::graphv( @rrd_job_grp);
#		my $ERR=RRDs::error;
#		die "ERROR while updating rrd file: $ERR\n" if $ERR;
#	}
#}
#given("$params->{mode}") {
if ("$params->{mode}" eq "maui") {
		$dibujo=RRDs::graphv(@maui_share);
		my $ERR=RRDs::error;
		die "ERROR while updating rrd file: $ERR\n" if $ERR;
}elsif ("$params->{mode}" eq "queue") {
		$dibujo=RRDs::graphv(@rrd_job_queue);
		my $ERR=RRDs::error;
		die "ERROR while updating rrd file: $ERR\n" if $ERR;
}elsif ("$params->{mode}" eq "eff") {
		$dibujo=RRDs::graphv(@job_by_eff);
		my $ERR=RRDs::error;
		die "ERROR while updating rrd file: $ERR\n" if $ERR;
}elsif ("$params->{mode}" eq "torque") {
		$dibujo=RRDs::graphv( @rrd_job_grp);
		my $ERR=RRDs::error;
		die "ERROR while updating rrd file: $ERR\n" if $ERR;
}

print header('image/png');
print ($dibujo->{image});
print end_html;

#print start_html
#print h1("HOLA");
#print (Dumper $params);
#print ("<br>");
#print ($ganglia_path);
#print ("<br>");
#print ($dates->{$params->{r}});

sub create_rrd_line {
	my $array=shift;
	# We recieve global reference to $array, file_name($_[0]), field ($_[1]), color ($_[2]), tittle $_[3]
	
	system(`echo $_[1]$_[3] >> /tmp/kaka`);
	push(@$array, "DEF:$_[1]$_[3]=$_[0]:sum:AVERAGE");
	if (grep {$_ =~ "AREA"} @$array) {
		push(@$array, "STACK:$_[1]$_[3]$_[2]:$_[1]_jobs");
	}else{
		push(@$array, "AREA:$_[1]$_[3]$_[2]:$_[1]_jobs");
	}
}
