#!/bin/bash

IFS="
"
ganglia_path='/var/lib/ganglia/rrds/Batch System/pbs04.pic.es/'
output_path='/var/www/html/ganglia/graph.d'
color_file='/etc/monpetitami.d/colors'

for eff in 20 50 80
do
output_file="$output_path/torque_eff_${eff}_by_group_report.json"
echo '{
   "report_name" : "'${eff}'_eff_by_group",
   "report_type" : "standard",
   "title" : "'${eff}'_eff_by_group",
   "vertical_label" : "Shares",
   "series" : [  ' >  $output_file
        line=1
        for file in $ganglia_path/Eff_$eff*
                do
                        file_name=$(basename $file)
                        graph=$(echo $file_name|sed 's/.rrd//' )
                        group=$(echo $graph|cut -d"_" -f4)
                        color=$(sed -n "$line p" ${color_file}${eff})
                        echo '{ "metric": "'$graph'", "color": "'$color'", "label": "'$group'", "stack_width": "2", "type": "stack" },' >> $output_file
                        let line++
                done
        sed -i '$s/,$//' $output_file 
        echo '] }' >> $output_file
done
