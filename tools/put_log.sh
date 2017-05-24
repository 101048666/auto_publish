#!/bin/bash


#File Name:put_log.sh
#Author: WangYue
#Mail: 101048666@qq.com
#Created Time: 2017年05月05日 星期五 14时13分57秒

dt=`date`
if [ "$1" = "" ];then
    while read line
    do
    if [ ! -n $2 ];then
        echo "[ $dt ] $line"
    else
        echo "[ $dt ] $line"
        echo $2 > /dev/null
    fi
    done
    exit 0
fi

if [ ! -n $2 ];then
    echo "[ $dt ] $1"
    exit 0
else
    echo "[ $dt ] $1"
    echo $2 > /dev/null
    exit 0
fi
