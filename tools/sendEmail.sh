#!/bin/bash
 
p_name=$1
body=$2


#读取配置文件和方法
temp_dir=$(cd `dirname $0`; pwd)
config=$temp_dir/mail_bak.conf
to_mail=`cat $config | grep -v "#" |grep  "sendto" | awk -F= '{print $2}' | sed 's/,/ /g'`


for i in `cat $config`
do
    send_user_mail=`echo $i|awk -F , '{print $1}'`
    send_server=`echo $i|awk -F , '{print $3}'`
    send_password=`echo $i|awk -F , '{print $2}'`
    for ttt in $to_mail
    do
        echo $ttt
        result=`$temp_dir/sendEmail  -f $send_user_mail -t "$ttt" -s $send_server -u "$p_name auto publish result" -o message-content-type=html -o message-charset=utf8 -xu $send_user_mail -xp $send_password -o message-file=$body`
        res=`echo $result|grep successfully`
    done
    if [[ "${i}x" =~ "sendto" ]];then
        continue
    fi
    if [ -n "$res" ]; then
       exit 0 
    fi

done
echo "send mail failed"
exit 1
