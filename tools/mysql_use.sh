#!/bin/bash


#File Name:tools/mysql_use.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年04月21日 星期五 01时34分52秒

#读取配置文件
temp_dir=$(cd `dirname $0`; pwd)
config=$(cd $temp_dir; cd ../; pwd)/auto_publish_config.conf

getconfig(){
        config_file=$1
            section=$2
                key=$3
                    value=`cat $config_file | awk 'BEGIN{FS="=";OFS=":";}/\['$section'\]/,/\[.*[^('$section')].*\]/{gsub(/[[:blank:]]*/,"",$1);if(NF==2 && $1=="'$key'"){gsub(/^[[:blank:]]*/,"",$2);gsub(/[[:blank:]]*$/,"",$2);print $2;}}'`
                        echo $value

}

#定义配置文件参数的数据字典以便对应配置文件中的内容
com_ip="mysql_url"
com_db="mysql_db"
com_user="mysql_user"
com_pass="mysql_pass"
com_port="mysql_port"
com_soft="mysql_soft"

#读取配置文件中启用的节点信息
profile=`sed -n '/ap_mysql/'p $config | awk -F= '{print $2}' | sed 's/,/ /g'`

#获取节点的ip、port、path
i=0
for onecom in $profile
do
    ip_res[$i]=$(getconfig $config $onecom $com_ip)
    db_res[$i]=$(getconfig $config $onecom $com_db)
    user_res[$i]=$(getconfig $config $onecom $com_user)
    pass_res[$i]=$(getconfig $config $onecom $com_pass)
    port_res[$i]=$(getconfig $config $onecom $com_port)
    soft_res[$i]=$(getconfig $config $onecom $com_soft)
    let i++
done

i=0
${soft_res[$i]} -u${user_res[$i]} -p${pass_res[$i]} -h${ip_res[$i]} -P${port_res[$i]} -BNe "use ${db_res[$i]};$1;"
