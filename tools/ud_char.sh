#!/bin/bash


#File Name:test.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月23日 星期二 15时50分23秒

#set -o xtrace



char=$1

num=`echo ${#char}`
res=""

PATTERN="[^0-9]"
i=0
while [ $i -lt $num ] 
do
    check=${char:$i:1}
    if [[ $check =~ $PATTERN ]];then
        res="$res$check"
    else
        echo $res
        exit 0
    fi
    let i++
done


echo $res
