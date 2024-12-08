
node_list=("$@")
uname="`whoami`"
localhost="`hostname`"

if [ ${#node_list[@]} -lt 1 ];
then
    echo "请输入建立ssh通道的主机名称!"
    exit 1
fi


echo "创建各节点之间的ssh通道"

echo "uname==${uname}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/known_hosts && chmod 600 ~/.ssh/known_hosts

echo "=======收集ssh通道信息======="
for hname in ${node_list[@]}
do
    echo "get $hname info"
    ssh-keyscan ${hname} >> ~/.ssh/known_hosts 2>/dev/null
done

echo "=创建各节点的ssh-keygen && 复制公钥到远程机器==="
for hname in ${node_list[@]}
do
    echo "Create $hname ssh-keygen"
    sshpass -p test1z ssh longer@$hname 'ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa -q'
    sshpass -p test1z ssh-copy-id longer@$hname
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
    if [ "$hname" == "$localhost" ]; then
        continue
    fi
    echo "复制文件到$hname"
    scp ~/.ssh/authorized_keys $hname:~/.ssh
    scp ~/.ssh/known_hosts $hname:~/.ssh
done

echo "==========ssh通道创建完成=========="
