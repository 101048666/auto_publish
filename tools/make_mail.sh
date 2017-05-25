#!/bin/bash


#File Name:make_mail.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月25日 星期四 13时55分27秒
#set -o xtrace

temp_dir=$(cd `dirname $0`; pwd)
model_dir=$(cd $temp_dir;cd ../publish_info;pwd)
model_file="$model_dir/mail_model"
info_file=$1

if [ -f "$info_file" ];then
    n=1
else
    echo "no file"
    exit 1
fi

dt=`date +%Y%m%d%H%M%S`

mailfile="$model_dir/report_$dt.html"
\cp -rf  $model_file  $mailfile
while read line 
do
    if [[ "${line}x" =~ "project_name" ]];then
        p_name=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "version" ]];then
        version=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "product_manager" ]];then
        pro_m=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "product_director" ]];then
        pro_dir=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "dev_engineer" ]];then
        dev_e=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "dev_manager" ]];then
        dev_m=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "technical_director" ]];then
        tech_dir=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "test_engineer" ]];then
        test_e=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "test_manager" ]];then
        test_m=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "operation_engineer" ]];then
        oper_e=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "operation_manager" ]];then
        oper_m=`echo $line|awk -F '=' '{print $2}'`
    fi
    if [[ "${line}x" =~ "repair" ]];then
        echo $line | awk -F '=' '{print $2}' >> temp_file
    fi
    if [[ "${line}x" =~ "report" ]];then
        echo $line | awk -F '=' '{print $2}' >> temp_file_t
    fi
done < $info_file

sed -i '/p_name/d' $mailfile
sed -i "/auto_publish_result/a\<tr><td>应用：</td><td>${p_name}</td></tr><!--p_name -->" $mailfile 

sed -i '/version/d' $mailfile
sed -i "/p_name/a\<tr><td>版本：</td><td>${version}</td></tr><!--version -->" $mailfile

sed -i '/product manager/d' $mailfile
sed -i "/version/a\<tr><td>产品经理：</td><td>${pro_m}</td></tr><!--product manager-->" $mailfile

sed -i '/Product Director/d' $mailfile
sed -i "/product manager/a\<tr><td>产品总监：</td><td>${pro_dir}</td></tr><!-- Product Director-->" $mailfile

sed -i '/development Engineers/d' $mailfile
sed -i "/Product Director/a\<tr><td>研发工程师：</td><td>${dev_e}</td></tr><!--development Engineers -->" $mailfile

sed -i '/development manager/d' $mailfile
sed -i "/development Engineers/a\<tr><td>研发经理：</td><td>${dev_m}</td></tr><!--development manager-->" $mailfile

sed -i '/Technical Director/d' $mailfile
sed -i "/development manager/a\<tr><td>技术总监：</td><td>${tech_dir}</td></tr><!--Technical Director-->" $mailfile

sed -i '/test engineer/d' $mailfile
sed -i "/Technical Director/a\<tr><td>测试工程师：</td><td>${test_e}</td></tr><!--test engineer-->" $mailfile

sed -i '/test manager/d' $mailfile
sed -i "/test engineer/a\<tr><td>测试经理：</td><td>${test_m}</td></tr><!--test manager-->" $mailfile

sed -i '/Operation Engineer/d' $mailfile
sed -i "/test manager/a\<tr><td>运维工程师：</td><td>${oper_e}</td></tr><!--Operation Engineer-->" $mailfile

sed -i '/Operation manager/d' $mailfile
sed -i "/Operation Engineer/a\<tr><td>运维主管：</td><td>${oper_m}</td></tr><!--Operation manager -->" $mailfile

i=0
while read update  
do
    m=`expr $i + 1`
    sed -i "/repair text $i/a\\${update}<br/><!--repair text $m-->" $mailfile
    let i++
done < temp_file

i=0
while read report
do
    m=`expr $i + 1`
    sed -i "/report $i/a\\$report<br/><!--report $m -->" $mailfile
    let i++
done < temp_file_t

rm -rf temp_file
rm -rf temp_file_t
echo $mailfile
