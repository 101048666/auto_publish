#!/bin/bash


#File Name:auto_publish.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年04月21日 星期五 01时30分42秒

#!/bin/bash
comand=$1
project=$2
version=$3 
sleeptime=$4
temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$(cd $temp_dir/tools;pwd)
config=$temp_dir/auto_publish_config.conf

mysql_test=`$tools_dir/mysql_use.sh "select 1"`
if [[ "${mysql_test}x" = "x" ]];then
    $tools_dir/put_log.sh "mysql connection error !!!!"
    exit 1
else
    $tools_dir/put_log.sh "mysql connection ok ......GO !!!"
fi

case $comand in                                                                                                                                                                          
    "init")
     $tools_dir/put_log.sh "init...... $temp_dir/ctl/auto_init.sh"       
     $temp_dir/ctl/auto_init.sh
     ;;
    "upload")
     echo $comand
     ;;
    "online")
     $temp_dir/ctl/auto_publish_online.sh $project $version $sleeptime
     ;;
    "help")
     echo $comand
     ;;
    *)
     echo 'please cmd auto_publish help to get help info'
     ;;
esac
