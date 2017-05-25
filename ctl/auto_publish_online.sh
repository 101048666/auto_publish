#!/bin/bash


#File Name:auto_publish_online.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月18日 星期四 11时26分09秒

#for docker

temp_dir=$(cd `dirname $0`; pwd)
tools_dir=$(cd $temp_dir;cd ../tools;pwd)
temp_file_phy_m=$tools_dir/temp_file_phy_m
ext_dir=$(cd $temp_dir;cd ../ext;pwd)
temp_file_vir=$tools_dir/temp_file_vir

p_name=$1
version=$2

sleeptime=0
if [[ "$3"x != x ]];then
    sleeptime=$3
fi

$tools_dir/put_log.sh "get phy_machine info from db to temp file $temp_file_phy_m"

$tools_dir/mysql_use.sh "select concat(ip,':',machine_user,':',machine_pass,':',ssh_port,':',project_lib_dir,':',remote_lib_dir,':',vm_type,':',id) from phy_machine where is_use = 1 ;" > $temp_file_phy_m
$tools_dir/mysql_use.sh "select concat(phy_machine_id,':',ip,':',vir_machine_code,':',publish_dir) from virtual_machine where name like '%${p_name}%'" > $temp_file_vir
#use virtual_machine's name is bug;use app's project_name is right
while read line
do
    ip=`echo $line | awk -F ':' '{print $1}'`
    user=`echo $line | awk -F ':' '{print $2}'`
    pass=`echo $line | awk -F ':' '{print $3}'`
    port=`echo $line | awk -F ':' '{print $4}'`
    project_l_dir=`echo $line | awk -F ':' '{print $5}'`
    remote_l_dir=`echo $line | awk -F ':' '{print $6}'`
    vm_type=`echo $line | awk -F ':' '{print $7}'`
    phy_mid=`echo $line | awk -F ':' '{print $8}'`
    $tools_dir/put_log.sh "$ip,$user,$pass,$port,$project_l_dir,$remote_l_dir,$vm_type"
    if [ -f $remote_l_dir/project_package/$p_name/${p_name}_${version}.war ] && [ -f $remote_l_dir/project_package/$p_name/${p_name}_${version}.ini ];then
        $tools_dir/put_log.sh  "select concat(phy_machine_id,':',ip,':',vir_machine_code,':',publish_dir) from virtual_machine where phy_machine_id = '${phy_mid}' and name like '%${p_name}%';"
        $tools_dir/mysql_use.sh "select concat(phy_machine_id,':',ip,':',vir_machine_code,':',publish_dir) from virtual_machine where phy_machine_id = '${phy_mid}' and name like '%${p_name}%';" > $temp_file_vir
        while read line
        do
            vir_code=`echo $line | awk -F ':' '{print $3}'`
            vir_pub=`echo $line | awk -F ':' '{print $4}'`
            $tools_dir/put_log.sh "$vir_pub   $vir_code"
            $tools_dir/put_log.sh "$ip unzip --$project_l_dir/project_package/$p_name/${p_name}_${version}.war-- package to publish dir in $project_l_dir/publish_pro/$p_name/$version"
            $tools_dir/ssh_use.sh $ip $user $pass "mkdir -p $vir_pub/$version"
            $tools_dir/ssh_use.sh $ip $user $pass "unzip $project_l_dir/project_package/$p_name/${p_name}_${version}.war -d $vir_pub/$version/ROOT" | $tools_dir/put_log.sh
            $tools_dir/ssh_use.sh $ip $user $pass "rm -rf $vir_pub/webapps"
            $tools_dir/ssh_use.sh $ip $user $pass "cd $vir_pub/ && ln -s $version webapps"
            $tools_dir/ssh_use.sh $ip $user $pass "docker restart $vir_code"
            if [[ "${sleeptime}x" = "0x" ]];then
                continue
            fi
            sleep ${sleeptime}m
            echo "report=auto_publish at $p_name on $ip:$vir_pub/webapps  ok" >> $remote_l_dir/project_package/$p_name/${p_name}_${version}.ini
        done < $temp_file_vir
        rm -rf $temp_file_vir
    else
        $tools_dir/put_log.sh "$remote_l_dir/$p_name/${p_name}_${version}.war or $remote_l_dir/$p_name/${p_name}_${version}.ini is not exit"
        rm -rf $temp_file_vir
        break
    fi
done < $temp_file_phy_m

rm -rf $temp_file_phy_m

email=`$tools_dir/make_mail.sh`

$tools_dir/sendEmail.sh $p_name $email
rm -rf $email
