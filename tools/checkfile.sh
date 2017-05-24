#!/bin/bash


#File Name:checkfile.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月18日 星期四 11时15分56秒

temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$temp_dir
remote_dir=$1
local_dir=$2

ip=$3
user=$4
pass=$5



remote_file=$remote_dir/project_package/$6
local_file=$local_dir/project_package/$6

r_file=`du -b $remote_file`
l_file=`$tools_dir/ssh_use.sh $ip $user $pass du -b $local_file`

if [[ "${r_file}x" = "${l_file}x" ]];then
    echo "ok"
else
    echo "no"
fi
