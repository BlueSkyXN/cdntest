## 功能
通过批量HTTP请求，对同URL的不同IP进行可用性测试，可用于检查多节点、CDNIP、后端IP、源站IP等可用性状态检查的场景

## 安装

git clone https://github.com/BlueSkyXN/cdntest.git

注意直接复制、下载可能导致错误

net.ip 文件需要保存源站IP信息，一行一个IP

## 运行

cd本程序目录，比如说 cd /root/cdntest

然后运行 bash cdntest.sh 或者其他子文件即可，其他根据中文提示操作

支持Linux和Windows（需要Git For Windows）

## Source与修改

原版来自 https://cloud.tencent.com/developer/article/1458328

主要修改了源站IP判断的BUG（不知道哪来的）以及HEAD请求换成带UA的GET请求
