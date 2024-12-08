#!/bin/bash

echo "清理各节点ssh通道信息"

host_list=("$@")

for hname in ${host_list[@]}
do
   if [ "$hname" == "`hostname`" ]
   then
       rm -rf ~/.ssh
       continue
   fi
   sshpass -p test1z ssh -t -o StrictHostKeyChecking=no $hname 'rm -rf ~/.ssh'
done

echo "删除本地ssh通道信息"
rm -rf ~/.ssh
