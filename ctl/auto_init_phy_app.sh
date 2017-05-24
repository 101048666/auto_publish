#!/bin/bash


#File Name:auto_init.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月02日 星期二 22时28分47秒

temp_dir=$(cd `dirname $0`; pwd)
config=$(cd $temp_dir; cd ../; pwd)/auto_publish_config.conf 
getconfig(){
        Key=$3  
        Section=$2  
        Configfile=$1  
        ReadINI=`awk -F '=' '/\['$Section'\]/{a=1}a==1&&$1~/'$Key'/{print $2;exit}' $Configfile`    
        echo "$ReadINI"
}

tools_dir=$(cd $temp_dir;cd ../tools;pwd)
$tools_dir/put_log.sh "load auto_publish config_file config_info"
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
        vmtype=`$tools_dir/mysql_use.sh "select id from virtual_type where is_use=1 and name='${vm_type_res[$i]}'"`
        $tools_dir/mysql_use.sh "delete from phy_machine where ip = '${ip_res[$i]}'"
        $tools_dir/put_log.sh "insert into phy_machine (ip,name,machine_user,machine_pass,ssh_port,vm_type,online_time,project_lib_dir,remote_lib_dir,rsync_port) values ('${ip_res[$i]}','${name_res[$i]}','${user_res[$i]}','${pass_res[$i]}',${ssh_port_res[$i]},$vmtype,(select UNIX_TIMESTAMP()),'${local_lib_res[$i]}','${remote_dir}',${rsync_port_res[$i]});"
        $tools_dir/mysql_use.sh "insert into phy_machine (ip,name,machine_user,machine_pass,ssh_port,vm_type,online_time,project_lib_dir,remote_lib_dir,rsync_port) values ('${ip_res[$i]}','${name_res[$i]}','${user_res[$i]}','${pass_res[$i]}',${ssh_port_res[$i]},$vmtype,(select UNIX_TIMESTAMP()),'${local_lib_res[$i]}','${remote_dir}',${rsync_port_res[$i]});"
        
        let i++
    done

killall -9 auto_issue.sh inotifywait | $tools_dir/put_log.sh
rm -rf /usr/local/inotify | $tools_dir/put_log.sh


$tools_dir/put_log.sh "tar -zxvf auto_issue.tar.gz and auto_issue_server.tar.gz"    
auto_issue_dir=$(cd $temp_dir;cd ../;pwd)
cd $auto_issue_dir
$tools_dir/put_log.sh "tar -xzvf auto_issue.tar.gz" `tar -xzvf auto_issue.tar.gz`
auto_issue_dir=$(cd $temp_dir;cd ../auto_issue;pwd)
cd $auto_issue_dir
$tools_dir/put_log.sh "tar -xzvf auto_issue_server.tar.gz" `tar -xzvf auto_issue_server.tar.gz`
$tools_dir/put_log.sh "tar -xzvf inotify" `tar -xzvf inotify-tools-3.14.tar.gz`

cd ./inotify-tools-3.14
$tools_dir/put_log.sh "install inotify to monitoring remote_dir " `./configure --prefix=/usr/local/inotify 2>&1  && make 2>&1  && make install 2>&1`

$tools_dir/put_log.sh "get auto_issue config info"
for ip_t in ${ip_res[*]}
do
    ips="$ips $ip_t"
done
for port_t in ${rsync_port_res[*]}
do
    ports="$ports $port_t"
done

$tools_dir/put_log.sh "update auto_issue config_file"
#echo $ips
sed -i '/ip/d' $auto_issue_dir/auto_issue.conf
sed -i "/port/a\ip=$ips" $auto_issue_dir/auto_issue.conf

#echo $rss
sed -i '/port/d' $auto_issue_dir/auto_issue.conf
sed -i "/ip/a\port=$ports" $auto_issue_dir/auto_issue.conf

#dir
mkdir -p $remote_dir/project_package
temp_r_dir=`echo $remote_dir | sed 's#\/#\\\/#g'`
sed -i '/temp_dir/d' $auto_issue_dir/auto_issue.conf
sed -i "/user/a\dir=$temp_r_dir/project_package/" $auto_issue_dir/auto_issue.conf


#rsync_moudle
rsync_moudle=`cat $config | grep -v "#" |grep  phy_rsync_moudle | awk -F= '{print $2}' | sed 's/,/ /g'`
sed -i '/rsync_moudle/d' $auto_issue_dir/auto_issue.conf
sed -i "/user/a\rsync_moudle=$rsync_moudle" $auto_issue_dir/auto_issue.conf

$tools_dir/put_log.sh "tar -xzvf auto_issue_node.tar.gz"
#update rsync config
cd ..
$tools_dir/put_log.sh "tar -xzvf auto_issue_node.tar.gz" `tar -xzvf auto_issue_node.tar.gz`

$tools_dir/put_log.sh "update phy_appserver rsyncd.conf"
sed -i '/\[nntest\]/d' $auto_issue_dir/rsyncd.conf
sed -i "/motd/a\\[$rsync_moudle\]" $auto_issue_dir/rsyncd.conf


ip_admin=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
i=0
for ip in $ip_admin
do
    ip_ch=`echo $ip | awk -F . '{print $1}'`
    if [ $ip_ch = '192' ] || [ $ip_ch = '10' ] || [ $ip_ch = '172' ];then
        admin_ip_check[$i]=$ip
    fi
    let i++
done

i=0
for m_ip in ${ip_res[*]}
do
    t_ip=`echo $m_ip|awk -F . '{print $1"-"$2"-"$3"-"$4}'`
    cp $auto_issue_dir/rsyncd.conf $auto_issue_dir/${t_ip}_rsyncd.conf

    temp_r_dir=`echo ${local_lib_res[$i]}/project_package | sed 's#\/#\\\/#g'`

    sed -i '/path/d' $auto_issue_dir/${t_ip}_rsyncd.conf
    sed -i "/\[$rsync_moudle\]/a\path = $temp_r_dir" $auto_issue_dir/${t_ip}_rsyncd.conf
    sed -i '/port/d' $auto_issue_dir/${t_ip}_rsyncd.conf
    sed -i "/path/a\port = ${rsync_port_res[$i]}" $auto_issue_dir/${t_ip}_rsyncd.conf
    ac_ip_mask=`echo ${ip_res[$i]}| awk -F . '{print $1"."$2"."$3}'` 
    host_allow=`echo $ac_ip_mask".0/24"`
    sed -i '/hosts allow/d' $auto_issue_dir/${t_ip}_rsyncd.conf
    sed -i "/auth user/a\hosts allow = $host_allow" $auto_issue_dir/${t_ip}_rsyncd.conf
    let i++
done

$tools_dir/put_log.sh "install rsync and config it on app phy_machine"
################################
#install rsync whith yum on app phy_machine
################################
i=0
for m_ip in ${ip_res[*]}
do
    expect -c "
    spawn ssh ${user_res[$i]}@$m_ip yum install -y rsync
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null
    let i++
done


\cp -rf ./auto_issue.conf /usr/local/inotify/
\cp -rf ./auto_issue.sh /usr/local/inotify/
\cp -rf ./client_passwd /usr/local/inotify/
\cp -rf ./exclude.list /usr/local/inotify/

################################
#cp rsyncd.conf and rsync.pass to app phy_machine's /etc/ and startup rsync
###############################
$tools_dir/put_log.sh "put rsyncd.conf and rsync.pass to phy_machine and startup rsync"
i=0
for m_ip in ${ip_res[*]}
do
    expect -c "
    spawn ssh -p ${ssh_port_res[$i]} ${user_res[$i]}@$m_ip killall -9 rsync 
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null 2>&1
    expect -c "
    spawn ssh -p ${ssh_port_res[$i]}  ${user_res[$i]}@$m_ip rm -rf /etc/rsyncd.conf /etc/rsync.pass /var/run/rsyncd.pid
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null 2>&1


    t_ip=`echo $m_ip|awk -F . '{print $1"-"$2"-"$3"-"$4}'`
    expect -c "
    spawn scp -P ${ssh_port_res[$i]} $auto_issue_dir/${t_ip}_rsyncd.conf ${user_res[$i]}@$m_ip:/etc/rsyncd.conf
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null

    expect -c "
    spawn scp -P ${ssh_port_res[$i]} $auto_issue_dir/rsync.pass ${user_res[$i]}@$m_ip:/etc/rsync.pass
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null

    expect -c "
    spawn ssh -p ${ssh_port_res[$i]}  ${user_res[$i]}@$m_ip chmod 600 /etc/rsyncd.conf /etc/rsync.pass
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null
    
    expect -c "
    spawn ssh -p ${ssh_port_res[$i]}  ${user_res[$i]}@$m_ip mkdir -p ${local_lib_res[$i]}/publish_pro && mkdir -p ${local_lib_res[$i]}/project_package
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null
    
    expect -c "
    spawn ssh -p ${ssh_port_res[$i]}  ${user_res[$i]}@$m_ip killall -9 rsync && rm -rf /var/run/rsyncd.pid
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null
    
    expect -c "
    spawn ssh -p ${ssh_port_res[$i]}  ${user_res[$i]}@$m_ip /usr/bin/rsync --daemon --config=/etc/rsyncd.conf
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null
    
    expect -c "
    spawn ssh -p ${ssh_port_res[$i]}  ${user_res[$i]}@$m_ip iptables -I INPUT 4 -m state --state NEW -m tcp -p tcp --dport ${rsync_port_res[$i]} -j ACCEPT
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null
    
    expect -c "
    spawn ssh -p ${ssh_port_res[$i]}  ${user_res[$i]}@$m_ip sed -i '/22/a\-A INPUT -m state --state NEW -m tcp -p tcp --dport ${rsync_port_res[$i]} -j ACCEPT' /etc/sysconfig/iptables
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"${pass_res[$i]}\r\";exp_continue};
    }" > /dev/null

    echo "$m_ip  remote_lib_dir:$remote_dir  local_lib_dir:${local_lib_res[$i]}   app publish dir:${local_lib_res[$i]}/publish_pro  project package dir\[zip&war&tar\]:${local_lib_res[$i]}/project_package" >> jjjjjjjj
    let i++
done


chmod 600 /usr/local/inotify/auto_issue.conf /usr/local/inotify/client_passwd
chmod 755 /usr/local/inotify/auto_issue.sh

$tools_dir/put_log.sh "startup inotify and phy_appserver_rsync"
/usr/local/inotify/auto_issue.sh > /usr/local/inotify/auto_issue.log 2>&1  &

$tools_dir/put_log.sh "phy_appserver project lib and remote_admin_lib install finished~~~~~~"

cat jjjjjjjj | $tools_dir/put_log.sh
rm -rf jjjjjjjj

test_ok=`$tools_dir/mysql_use.sh "select * from phy_machine"`
if [[ ! -n $test_ok ]];then
    $tools_dir/put_log.sh "phy_machine info insert into DB error !!!!!"
    exit 1
else
    echo "ok" | tee | $tools_dir/put_log.sh
fi
#$temp_dir/auto_init_virtual_machine.sh 
