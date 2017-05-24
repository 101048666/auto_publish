#!/bin/bash
#set -o xtrace

#File Name:tools/ssh_use.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月08日 星期一 15时45分14秒
#set -o xtrace

temp_dir=$(cd `dirname $0`; pwd)
ip=$1
user=$2
pass=$3
cmd=$4
port=$5
temp_=$temp_dir/temp_file
res=$temp_dir/res_file
> $res

if [ "${port}x" = "x" ];then
    expect -c "
    spawn ssh $user@$ip $cmd
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"$pass\r\";exp_continue};
    }" > $temp_
else
    expect -c "
    spawn ssh -p $port $user@$ip $cmd
    expect {
    \"(yes/no)?\" {send \"yes\r\";exp_continue};
    \"password:\" {send \"$pass\r\";exp_continue};
    }" > $temp_
fi

while read line
do
        if [[ "${line}x" =~ "spawn" ]] || [[ "${line}x" =~ "$user@$ip" ]] || [[  "${line}x" =~ "POSSIBLE BREAK-IN ATTEMPT" ]];then
            continue
        fi
        echo $line >> $res
done < $temp_
cat $res
rm -rf $res
rm -rf $temp_
