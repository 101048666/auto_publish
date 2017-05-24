#!/bin/bash


#File Name:load_log.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月22日 星期一 19时59分30秒

p_name=$1
num=$2
if [ ! -n $num ];then
    num=200
fi


temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$temp_dir


$tools_dir/mysql_use.sh "select concat(v.ip,':',v.publish_dir,':',p.machine_user,':',p.machine_pass) from virtual_machine v , phy_machine p where p.id = v.phy_machine_id and v.name like '%study%' ;" > temp_jj_file

while read line
do
    ip=`echo $line |awk -F ':' '{print $1}'`
    user=`echo $line | awk -F ':' '{print $3}'`
    pass=`echo $line | awk -F ':' '{print $4}'`
    dir=`echo $line | awk -F ':' '{print $2}'`

    $tools_dir/put_log.sh "it is $p_name : $ip"
    $tools_dir/ssh_use.sh $ip $user $pass "tail -${num} $dir/logs/catalina.out" | $tools_dir/put_log.sh
done < temp_jj_file
rm -rf temp_jj_file
