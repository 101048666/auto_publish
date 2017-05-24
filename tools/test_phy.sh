#!/bin/bash


#File Name:../tools/test_phy.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月17日 星期三 13时25分17秒
#set -o errexit
#set -o xtrace


temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$(cd $temp_dir;pwd)
ext_dir=$(cd $temp_dir;cd ../ext;pwd)
>$tools_dir/test_phy.log
config=$(cd $temp_dir; cd ../; pwd)/auto_publish_config.conf 
getconfig(){
        Key=$3  
        Section=$2  
        Configfile=$1  
        ReadINI=`awk -F '=' '/\['$Section'\]/{a=1}a==1&&$1~/'$Key'/{print $2;exit}' $Configfile`    
        echo "$ReadINI"

}

tools_dir=$(cd $temp_dir;cd ../tools;pwd)
#定义配置文件参数的数据字典以便对应配置文件中的内容
com_ip="ip"
com_name="name"
com_user="machine_user"
com_pass="machine_pass"
com_ssh_port="ssh_port"
com_vm_type="vm_type"
com_local_lib="local_lib"
com_remote_lib="remote_lib"
com_rsync_port="rsync_port"
#读取配置文件中启用的节点信息
profile=`cat $config | grep -v "#" |grep  phy_machine | awk -F= '{print $2}' | sed 's/,/ /g'`
#获取节点的ip、port、path
i=0
remote_dir=`cat $config | grep -v "#" |grep  remote_lib | awk -F= '{print $2}' | sed 's/,/ /g'`
for onecom in $profile
    do
        ip_res[$i]=$(getconfig $config $onecom $com_ip)
        name_res[$i]=$(getconfig $config $onecom $com_name)
        user_res[$i]=$(getconfig $config $onecom $com_user)
        pass_res[$i]=$(getconfig $config $onecom $com_pass)
        ssh_port_res[$i]=$(getconfig $config $onecom $com_ssh_port)
        vm_type_res[$i]=$(getconfig $config $onecom $com_vm_type)
        local_lib_res[$i]=$(getconfig $config $onecom $com_local_lib)
        rsync_port_res[$i]=$(getconfig $config $onecom $com_rsync_port)

        $tools_dir/put_log.sh "start test ssh for   ip:${ip_res[$i]}  port:${ssh_port_res[$i]}  user:${user_res[$i]}   pass:${pass_res[$i]}"
        res_124=`$tools_dir/ssh_use.sh ${ip_res[$i]} ${user_res[$i]} ${pass_res[$i]} "echo 1"`
        if [[ "$res_124" =~ "1" ]];then
            $tools_dir/put_log.sh "${ip_res[$i]},is ok"
            let i++
            continue
        fi
        $tools_dir/put_log.sh "ip:${ip_res[$i]}  failed;check ip username password port..... " 
        let i++
    done
