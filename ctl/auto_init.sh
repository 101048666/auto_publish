#!/bin/bash


#File Name:auto_init.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月02日 星期二 22时28分47秒

temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$(cd $temp_dir;cd ../tools;pwd)

$tools_dir/put_log.sh "start init"
$tools_dir/put_log.sh "step 1 init project lib(admin_lib,phy_machine_appserver,rsync each other)"
$temp_dir/auto_init_phy_app.sh
if [ $? -eq 0 ];then
    $tools_dir/put_log.sh "step 2 init all virtual_machine info)"
    $temp_dir/auto_init_virtual_machine.sh
fi
