#!/bin/bash


#File Name:ext/docker_check.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月09日 星期二 16时21分13秒

#set -o xtrace

temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$(cd $temp_dir;cd ../tools;pwd)

ip=$1
user=$2
pass=$3

mid=`$tools_dir/mysql_use.sh "select id from phy_machine where ip='$ip'"`
publish_dir=`$tools_dir/mysql_use.sh "select project_lib_dir from phy_machine where id = $mid"`
$tools_dir/mysql_use.sh "delete from virtual_machine where ip = '${ip}'"
$tools_dir/mysql_use.sh "delete from app_project where virtual_machine_id in (select id from virtual_machine where ip = '${ip}')"
$tools_dir/ssh_use.sh $ip $user $pass "ps -e | grep 'docker'"> $tools_dir/res_is_docker
vir_type=`cat $tools_dir/res_is_docker | grep 'docker' | head -1`
if [ "${vir_type}x" = "x" ];then
    $tools_dir/put_log.sh "no docker,it ip : $ip "
    $tools_dir/put_log.sh "check docker service status 'run' or 'installed'"
    exit 1
fi
rm -rf $tools_dir/res_is_docker

     
$tools_dir/ssh_use.sh $ip $user $pass "docker ps" > $tools_dir/res_vir_m
while read line 
do
    #check the docker is running and have any CONTAINER 
    check=`echo $line | grep CONTAINER`
    if [ "${check}x" != "x" ];then
        continue
    fi
    
    #get CONTAINER ID in virname 
    virname=`echo $line | awk '{print $1}'`

    #get CONTAINER NAME in virname_human
    virname_human=`$tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.Name}}' $virname" | awk -F '/' '{print $2}'`
$tools_dir/put_log.sh "$virname $virname_human"

    #get CONTAINER -v info with cmd "docker run" 
    $tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.HostConfig.Binds}}' $virname" > $tools_dir/res_one_dc
    vm_mount=`cat $tools_dir/res_one_dc|cut -d '[' -f2|cut -d ']' -f1 `
    it_vm_mount=""
    for it in $vm_mount
    do
        if [ "${it}x" = "<nox" ];then
            break
        fi
        it_vm_mount="$it_vm_mount -v $it "
    done
    rm -rf $tools_dir/res_one_dc
$tools_dir/put_log.sh "$virname $it_vm_mount"

    #get CONTAINER -p info with cmd "docker run"
    $tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.HostConfig.PortBindings}}' $virname" > $tools_dir/res_one_dcp
    vm_port=`cat $tools_dir/res_one_dcp`
    echo $vm_port | grep -o '[0-9]\+' > $tools_dir/temp_port
    m=1
    it_vm_port=""
    it_vm_port_v="a"
    it_vm_port_m="b"
    while read t_port
    do
        if [ "${t_port}x" = "<nox" ];then
            break
        fi
        o=$(($m%2))
        if [ $o -eq 1 ];then
            it_vm_port_v=$t_port
        fi
        if [ $o -eq 0 ];then
            it_vm_port_m=$t_port
        fi
        if [ "$it_vm_port_v" = "a" ];then
            let m++
            continue
        fi
        if [ "$it_vm_port_m" = "b" ];then
            let m++
            continue
        fi
        it_vm_port="-p $it_vm_port_m:$it_vm_port_v $it_vm_port"
        it_vm_port_v="a"
        it_vm_port_m="b"
        let m++
    done < $tools_dir/temp_port
    rm -rf $tools_dir/temp_port 
    rm -rf $tools_dir/res_one_dcp
$tools_dir/put_log.sh "$virname $it_vm_port"

    #get CONTAINER --dns info and --add-host info with cmd "docker run"
    $tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.HostConfig.ExtraHosts}}' $virname" > $tools_dir/res_one_dc
    vm_host=`cat $tools_dir/res_one_dc|cut -d '[' -f2|cut -d ']' -f1 `
    it_vm_host=""
    for it in $vm_host
    do
        if [ "${it}x" = "<nox" ];then
            break
        fi
        it_vm_host="$it_vm_host --add-host=$it "
    done
    rm -rf $tools_dir/res_one_dc
$tools_dir/put_log.sh "$virname $it_vm_host"
    
    $tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.HostConfig.Dns}}' $virname" > $tools_dir/res_one_dc
    vm_dns=`cat $tools_dir/res_one_dc|cut -d '[' -f2|cut -d ']' -f1 `
    it_vm_dns=""
    for it in $vm_dns
    do
        if [ "${it}x" = "<nox" ];then
            break
        fi
        it_vm_dns="$it_vm_dns --dns=$it "
    done
    rm -rf $tools_dir/res_one_dc

$tools_dir/put_log.sh "$virname $it_vm_dns"
    $tools_dir/put_log.sh "insert into virtual_machine (name,ip,phy_machine_id,online_time,publish_dir,vir_machine_code,structure_parameter) values ('${virname_human}','${ip}',$mid,(select UNIX_TIMESTAMP()),'${publish_dir}/publish_pro/${virname_human}','${virname}','${it_vm_port} ${it_vm_host} ${it_vm_dns} ${it_vm_mount} --name=${virname_human} --hostname=${virname_human}')"
    $tools_dir/mysql_use.sh "insert into virtual_machine (name,ip,phy_machine_id,online_time,publish_dir,vir_machine_code,structure_parameter) values ('${virname_human}','${ip}',$mid,(select UNIX_TIMESTAMP()),'${publish_dir}/publish_pro/${virname_human}','${virname}','${it_vm_port} ${it_vm_host} ${it_vm_dns} ${it_vm_mount} --name=${virname_human} --hostname=${virname_human}')"
   


    
# for ttcdw input table app_project
    run_type_list=`$tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.Config.Entrypoint}}' $virname"`
    vm_id=`$tools_dir/mysql_use.sh "select id from virtual_machine where ip='${ip}' and vir_machine_code='${virname}';"`
    run_type_list=`echo $run_type_list|cut -d '[' -f2|cut -d ']' -f1`
    if [[ "${run_type_list}x" =~ "nil" ]] || [[ "${run_type_list}" =~ "no value" ]] ;then
        run_type_list=`$tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.Config.Cmd}}' $virname"`
        run_type_list=`echo $run_type_list|cut -d '[' -f2|cut -d ']' -f1`
    elif [[  "${run_type_list}x" = "x" ]];then
        run_type_list=`$tools_dir/ssh_use.sh $ip $user $pass "docker inspect --format '{{.Config.Cmd}}' $virname"`
        run_type_list=`echo $run_type_list|cut -d '[' -f2|cut -d ']' -f1`
    fi
    if [[ "${run_type_list}x" =~ "tomcat" ]];then
        vir_sql_name=`$tools_dir/ud_char.sh $virname_human`
        $tools_dir/mysql_use.sh "insert into app_project (app_name,start_cmd,stop_cmd,restart_cmd,online_time,app_version,app_type,virtual_machine_id) select '$vir_sql_name',concat('docker start ',vir_machine_code),concat('docker stop ',vir_machine_code),concat('docker restart ',vir_machine_code),online_time,'v1.0.0',1,id  from virtual_machine where ip='${ip}' and vir_machine_code='${virname}'; "
    elif [[ "${run_type_list}x" =~ "apachectl" ]];then
        vir_sql_name=`$tools_dir/ud_char.sh $virname_human`
        $tools_dir/mysql_use.sh "insert into app_project (app_name,start_cmd,stop_cmd,restart_cmd,online_time,app_version,app_type,virtual_machine_id) select '$vir_sql_name',concat('docker start ',vir_machine_code),concat('docker stop ',vir_machine_code),concat('docker restart ',vir_machine_code),online_time,'v1.0.0',2,id  from virtual_machine where ip='${ip}' and vir_machine_code='${virname}'; "
    elif [[ "${run_type_list}x" =~ "pure-config" ]];then
        vir_sql_name=`$tools_dir/ud_char.sh $virname_human`
        $tools_dir/mysql_use.sh "insert into app_project (app_name,start_cmd,stop_cmd,restart_cmd,online_time,app_version,app_type,virtual_machine_id) select '$vir_sql_name',concat('docker start ',vir_machine_code),concat('docker stop ',vir_machine_code),concat('docker restart ',vir_machine_code),online_time,'v1.0.0',3,id  from virtual_machine where ip='${ip}' and vir_machine_code='${virname}'; "
    elif [[ "${run_type_list}x" =~ "sshd" ]];then
        vir_sql_name=`$tools_dir/ud_char.sh $virname_human`
        $tools_dir/mysql_use.sh "insert into app_project (app_name,start_cmd,stop_cmd,restart_cmd,online_time,app_version,app_type,virtual_machine_id) select '$vir_sql_name',concat('docker start ',vir_machine_code),concat('docker stop ',vir_machine_code),concat('docker restart ',vir_machine_code),online_time,'v1.0.0',4,id  from virtual_machine where ip='${ip}' and vir_machine_code='${virname}'; "
    fi
done < $tools_dir/res_vir_m
rm -rf $tools_dir/res_vir_m

