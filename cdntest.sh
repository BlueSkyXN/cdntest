#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# Created by Johnnyxsu from TencentCloud
# Based On https://cloud.tencent.com/developer/article/1458328
# Modified By BlueSkyXN https://www.blueskyxn.com/
test_source_availability(){
if [ -s "/tmp/source_availability.log" ]; then rm -rf /tmp/source_availability.log ;fi


echo "CDNTEST检测多节点可用性脚本 By BlueSkyXN"
echo "---------------------------------------------------"
echo "需要把源站IP复制到该脚本相同目录下的net.ip文件内"
echo "默认UA是Chrome v103+Win10,以HTTP GET进行请求"
echo "仓库：https://github.com/BlueSkyXN/cdntest"
echo "---------------------------------------------------"

echo && read -e -p "设置循环测试次数（默认1次）：" loop
echo && read -e -p "请输入请求url：" url
#echo && read -e -p "请输入回源方式（HTTP输入1,HTTPS输入2，默认为1）：" method

http_or_hppts=`echo $url|awk -F':' '{print $1}'`

if [ $http_or_hppts == "http" ];then
	method=1
elif [ $http_or_hppts == "https" ];then
	method=2
else
	echo "输入请求url有误！！！"
fi

if [[ $method == 1 ]]; then
	echo && read -e -p "设置回源端口号（HTTP默认80）：" port
	if [ ! -n "$port" ];then port=80;fi
	count=1 #设置计数初始值 
	if [ ! -n "$loop" ];then loop=1;fi
	while [[ $count -le $loop ]]; do
		for ip in $(cat net.ip);do 
			echo "源站IP："$ip >>/tmp/source_availability.log
			echo "测试命令：curl -I "$url" --resolve $host:$port:$ip"
			curl -X GET "$url" -I -x $ip:$port --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36">>/tmp/source_availability.log
		done
		let ++count
	done

elif [[ $method == 2 ]]; then
	echo && read -e -p "设置回源端口号（HTTPS默认443）：" port
	if [ ! -n "$port" ];then port=443;fi
	echo && read -e -p "请输入回源HOST（默认为url的host）：" host
	if [ ! $host ];then host=`echo $url|awk -F'/' '{print $3}'`;fi
	count=1 #设置计数初始值
	if [ ! -n "$loop" ];then loop=1;fi
	while [[ $count -le $loop ]]; do
		for ip in $(cat net.ip);do
			echo "源站IP："$ip >>/tmp/source_availability.log
			echo "测试命令：curl -I "$url" --resolve $host:$port:$ip"
			curl -X GET "$url" -I --resolve $host:$port:$ip --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36">>/tmp/source_availability.log
		done
		let ++count
	done
fi
}

analysis_source_availability_log(){

source_IP_num=`cat net.ip|wc -l`
source_IP_num=$source_IP_num+1
test_num=`awk 'BEGIN{printf ('$source_IP_num'*'$loop')}'`
http_code_num=`cat /tmp/source_availability.log |grep HTTP|wc -l`
echo "压测命令：curl -I $url "
echo "源站IP个数：$source_IP_num"
echo "轮询压测源站次数：$loop"
echo "总请求数为：$test_num"
echo "详细状态码如下:"
echo "    次数 状态码"
cat /tmp/source_availability.log|grep HTTP/ |awk '{print $2}'|sort|uniq -c|sort -nrk 1 -t' '
bool=`cat /tmp/source_availability.log |grep HTTP|grep -v 200|head -n 1|awk '{print $1}'`
if [ $bool ];then
	echo "异常状态码源站IP分布"
	echo "    次数 源站IP分布"
	cat /tmp/source_availability.log |grep -B 2 HTTP|grep -v 200|grep -B 2 HTTP|grep IP|sort|uniq -c|sort -nrk 1 -t' '
elif [ $http_code_num == $test_num ];then
	echo "所有源站都正常！！！"
else
	echo "------------------------------------------------------------------------------"
	echo "总请求数和HTTP状态码数量不一致，请查阅/tmp/source_availability.log获得详细信息"
fi
}


test_source_availability
analysis_source_availability_log
