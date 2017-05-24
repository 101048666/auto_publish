#!/bin/bash


#File Name:install_fb.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月19日 星期五 20时59分26秒


temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$temp_dir

$tools_dir/mysql_use.sh "select ip,machine_user,machine_pass,project_lib_dir from phy_machine" > ttttt

i=0
while read line
do
    ip_res[$i]=`echo $line|awk '{print $1}'`
    user_res[$i]=`echo $line | awk '{print $2}'`
    pass_res[$i]=`echo $line | awk '{print $3}'`
    lib_dir[$i]=`echo $line|awk '{print $4}'`
    let i++
done < ttttt

i=0
for m in ${ip_res[*]}
do
    echo "machine info ip:$m  user:${user_res[$i]}   pass:${pass_res[$i]}  lib:${lib_dir[$i]}" 
    fb_file="${lib_dir[$i]}/project_package/other/filebeat-5.1.2-x86_64.rpm"
    $tools_dir/ssh_use.sh $m ${user_res[$i]} ${pass_res[$i]} "\cp -rf ${lib_dir[$i]}/project_package/other/filebeat.yml /etc/filebeat/filebeat.yml"

    let i++
done


rm -rf ttttt

 
