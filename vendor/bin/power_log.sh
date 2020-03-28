LOGDIR=/data/vendor/power
LOGFILE=$LOGDIR"/power_state.txt"
BACKLIGHT_FILE="/sys/class/backlight/panel0-backlight/brightness"
BOARD_TEMP_FILE="/sys/class/thermal/thermal_message/board_sensor_temp"
dump_power_count=0
screen_on_sleep=90
screen_off_sleep=40


function dump_power_state()
{
	dump_power_count=`expr $dump_power_count + 1`
	echo "dump_power_count = $dump_power_count"
        
	if [ $dump_power_count -gt 60 ]; then
		echo "CURRENT :(uA)" > $LOGFILE
		dump_power_count=0
	else
		echo "CURRENT :(uA)" >> $LOGFILE
	fi
        
	cat /sys/class/power_supply/battery/current_now >> $LOGFILE

	echo "CPU LOAD ：" >> $LOGFILE
	top -b -n 1 -H -s 6 -o pid,tid,user,pr,ni,%cpu,s,virt,res,pcy,cmd,name -m 5  >> $LOGFILE

	#echo "MRESUMED ACTIVITIES :" >> $LOGFILE
	#dumpsys activity activities | grep mResumed >> $LOGFILE

	echo "KERNAL WAKELOCK :" >> $LOGFILE
	cat /d/wakeup_sources | awk '{if ($6 == "0"){}else if ( NR!=1 ) print $1}' >> $LOGFILE

	echo "ACTIVE SUBSYSTEM :" >> $LOGFILE
	cat /sys/power/rpmh_stats/master_stats | awk -F "[:]" '{if ($2=="0") {if (NR=="39") print "SLPI_ISLAND"} \
	if ($2=="0") {if (NR=="31") print "SLPI"} if ($2=="0") {if (NR=="23") print "CDSP" } \
	if ($2=="0") {if (NR=="15") print "ADSP"} if ($2=="0") {if (NR=="7") print "APPS"}}' >> $LOGFILE

	cat sys/power/system_sleep/stats | awk 'NR==1{print} NR==2{print}'  >> $LOGFILE

	echo "" >> $LOGFILE
}

while [ 1 ]
do
	current_backlight=($(cat $BACKLIGHT_FILE))
	board_temp=($(cat $BOARD_TEMP_FILE))
	echo "current_backlight = $current_backlight board_temp =$board_temp  00 "

	cur_time=$(date +%s)
	end_time=$(($cur_time+900))

	while [ $cur_time -lt $end_time ]; do
        if [ $current_backlight -eq 0 ] ;then
		sleep $screen_off_sleep;
        else
        sleep $screen_on_sleep;
        fi
		echo "current_backlight = $current_backlight board_temp =$board_temp  11 " 
		cur_time=$(date +%s)
	done

	last_board_temp=$board_temp
	current_board_temp=($(cat $BOARD_TEMP_FILE))
	delta=`expr $current_board_temp - $last_board_temp`
	nowtime=`date`
	echo "nowtime = $nowtime powerlogd current_backlight = $current_backlight last_board_temp =$last_board_temp  current_board_temp =$current_board_temp  delta =$delta "
	echo "nowtime = $nowtime powerlogd current_backlight = $current_backlight last_board_temp =$last_board_temp  current_board_temp =$current_board_temp  delta =$delta "  >> $LOGFILE

	if [ $current_backlight -eq 0 ] ;then
		if [[ $delta -gt 100 ]] || [[ $current_board_temp -gt 28000 ]];then
		dump_power_state
        fi
	else
		if [[ $delta -gt 500 ]] || [[ $current_board_temp -gt 38000 ]];then
			dump_power_state
		fi
	fi
done
