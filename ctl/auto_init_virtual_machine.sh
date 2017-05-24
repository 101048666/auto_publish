#!/bin/bash


#File Name:auto_init_virtual_machine.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月05日 星期五 17时29分40秒


#set -o xtrace



temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$(cd $temp_dir;cd ../tools;pwd)
temp_file_phy_m=$tools_dir/temp_file_phy_m
ext_dir=$(cd $temp_dir;cd ../ext;pwd)

$tools_dir/put_log.sh "get phy_machine info from db to temp file $temp_file_phy_m"

$tools_dir/mysql_use.sh "select concat(ip,':',machine_user,':',machine_pass,':',ssh_port,':',project_lib_dir,':',remote_lib_dir,':',vm_type) from phy_machine where is_use = 1;" > $temp_file_phy_m
cat  $temp_file_phy_m | while read phy_info
do
    ip=`echo $phy_info | awk -F : '{print $1}' `
    user=`echo $phy_info | awk -F : '{print $2}'`
    pass=`echo $phy_info | awk -F : '{print $3}'`
    port=`echo $phy_info | awk -F : '{print $4}'`
    local_lib=`echo $phy_info | awk -F : '{print $5}'`
    remote_lib=`echo $phy_info | awk -F : '{print $6}'`
    vm_type=`echo $phy_info | awk -F : '{print $7}'`
   
   case $vm_type in 
        1) ###"1" is mean's its vir_type is docker 
            $ext_dir/docker_check.sh $ip $user $pass
            ;;
        *)
            $tools_dir/put_log.sh "please realize the check virtual machine script in dir 'ext/'"
        ;;
    esac
done



rm -rf $temp_file_phy_m
