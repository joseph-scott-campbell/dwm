#!/bin/bash

get_cpu_usage(){
    cpu_usage=$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]"%"
    cpu_info="  ""$cpu_usage"
    echo $cpu_info
}

get_used_memory(){
    used_mem=$(free -h | awk {'print $3'} | sed -n 2p)
    available_mem=$(free -h | awk {'print $2'} | sed -n 2p)
    mem_info="  ""$used_mem""/""$available_mem"
}

get_network_data(){
    ip=$(ip a | sed -n 11p | awk {'print $2'} | awk -F \/ {'print $1'})
    if [ -n "$ip" ]
    then
        network_info=" 󰤨 "$ip""
    else
        network_info=" 󰤭  0.0.0.0"
    fi
}

get_battery_data(){
    battery_percent=$(</sys/class/power_supply/BAT0/capacity)
    battery_status=$(</sys/class/power_supply/BAT0/status)

    if [ "$battery_status" == "Charging" ]
    then
        battery_info="󰂄 "$battery_percent"%"
    elif [ "$battery_percent" -eq 100 ]
    then
        battery_info="󱊣 ""$battery_percent""%"
    elif [ "$battery_percent" -ge 50 ]
    then
        battery_info="󱊢 ""$battery_percent""%"
    elif [ "$battery_percent" -lt 50 ]
    then
        battery_info="󱊡""$battery_percent""%"
    fi
    
    echo "$battery_info"
}

sleep 1
feh --no-fehbg --bg-scale '/home/unnamed/.config/wallpaper/wallpaper.png'

while [ True ]
do
    get_battery_data
    get_used_memory
    get_network_data
    get_cpu_usage

    display_string="  "$battery_info"  "$mem_info"  "$cpu_info"  "$network_info"  ""$(date)"" "
    xsetroot -name "$display_string"
    sleep 1
done
