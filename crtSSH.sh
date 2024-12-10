#!/bin/bash
#Author: lilongqian
#Date: 2024-12-08

node_list=("$@")
username="`whoami`"
localhname="`hostname -s`"

if [ ${#node_list[@]} -lt 1 ];
then
    echo "请输入建立ssh通道的主机名称!"
    exit 1
fi


echo "创建各节点之间的ssh通道"

mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/known_hosts && chmod 600 ~/.ssh/known_hosts

echo "=======根据输入节点名称，在/etc/hosts中找到所有机器别名，再根据别名收集ssh通道信息======="
for sshname in ${node_list[@]}
do
    for linename in "$(cat /etc/hosts|grep $sshname|egrep -v '^$|127.0.0.1|::1|^\s*$')"
    do
        hnames=$(echo $linename|cut -d ' ' -f2-)
        for hname in ${hnames[@]}
        do
    	    echo "get $hname info"
    	    ssh-keyscan ${hname} >> ~/.ssh/known_hosts 2>/dev/null
        done
    done

done

echo "=创建各节点的ssh-keygen && 复制公钥到远程机器==="
for hname in ${node_list[@]}
do	
    echo "Create $hname ssh-keygen"
    sshpass -p yourpasswd ssh -o StrictHostKeyChecking=no -t ${username}@$hname 'ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -q'
    sshpass -p yourpasswd ssh-copy-id -f -o StrictHostKeyChecking=no ${username}@$hname
done

echo "====收集远程机器的公钥并存放到本地ssh认证文件中"
for hname in ${node_list[@]}
do	
    echo "Create $hname ssh-keygen"
    ssh -o StrictHostKeyChecking=no -t $hname 'cat ~/.ssh/id_rsa.pub' >> ~/.ssh/authorized_keys
done

echo "==复制authorized_keys与known_hosts到所有机器节点"
for hname in ${node_list[@]}
do	
    if [ "$hname" == "$localhname" ]; then
	continue
    fi
    echo "复制文件到$hname"
    scp ~/.ssh/authorized_keys $hname:~/.ssh
    scp ~/.ssh/known_hosts $hname:~/.ssh
done

echo "==========ssh通道创建完成=========="

