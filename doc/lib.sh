#!/bin/bash

##1.检测并安装必要软件包

packgecheck() {
	for i
    do
    	rpm -q $i &>/dev/null
        if (( $?!=0 ))
        then
        echo $i >>file1
        fi
	done

echo "开始安装CatiEZ 所需软件包,以下软件包为未安装的"
cat file1 |xargs

echo "准备安装请稍等....."

for p in `cat file1`
do
	echo "正在安装$p 请稍等..."
	yum install $p -y &>/dev/null  &&  echo "$p 已经安装成功"
done

}


##检测并卸载软件包

packgedel() {

for i in `cat file1`
do
	echo "正在卸载$i 请稍等....."
	yum remove  $i -y  &>/dev/null  &&  echo "$i 已经卸载完成"
done

}


##mysql数据库配置

sql() {
       
service mysqld restart &>/dev/null && echo "mysqld 服务已经重启成功"

mysqladmin -u root password cacti

echo "mysql 密码修改成功"

}


##CactiEZ配置

cactiez() {

echo "开始复制CactiEZ相关文件"

mkdir /cat

##判断系统版本

uname -r | grep x86 &>/dev/null
if(($?==0))
then
mount -o loop /cactiez/CactiEZ-10.1-x86_64.iso /cat &>/dev/null
mkdir -p /tmp/cactiez  &>/dev/null

cp  /cat/Packages/cactiez-i386.tgz  /tmp/cactiez
cd /tmp/cactiez
tar zxvf cactiez-i386.tgz  &>/dev/null
else
mount -o loop /cactiez/CactiEZ-10.1-i386.iso /cat &>/dev/null
mkdir -p /tmp/cactiez  &>/dev/null

cp  /cat/Packages/cactiez-x86_64.tgz  /tmp/cactiez
cd /tmp/cactiez
tar zxvf cactiez-x86_64.tgz  &>/dev/null
fi


cp -rf /tmp/cactiez/var/www/html/* /var/www/html
cp -rf /tmp/cactiez/usr/* /usr
cp -rf /tmp/cactiez/etc/* /etc

service mysqld restart  &>/dev/null
mysql -u root -pcacti -e  "create database cacti"
mysql -u root -pcacti -e  "GRANT ALL ON cacti.* TO cactiuser@localhost IDENTIFIED BY 'cactiuser'"

mysql -u cactiuser -pcactiuser cacti < /var/www/html/cactiez.sql

service mysqld stop  &>/dev/null
chmod -R 777 /var/www/html/log/
chmod -R 7755 /var/www/html/rra/
chmod -R 755 /var/www/html/scripts/
chmod -R 755 /usr/local/spine/bin/
chmod -R 755 /usr/local/rrdtool/bin/
chown -R apache:apache /var/www/html/

echo "*/5 * * * * php /var/www/html/poller.php" >/var/spool/cron/root
service crond restart  &>/dev/null
service mysqld restart  &>/dev/null

for service in httpd mysqld snmpd
do
chkconfig --level 35 $service on
done


}

##Cactiez 删除


delcat () {
	
    echo "正在清除残留文件....."
    rm -fr /tmp/*
    rm -fr /var/www/html/*
    rm -fr /usr/local/spine/*
    rm -fr /usr/local/rrdtool/*
    rm -fr /var/spool/cron/root
    rm -fr /etc/named.conf
    rm -fr /var/named/zzf.com.zone
#   rm -fr /etc/httpd/conf.d/host.conf
    rm -fr /var/lib/mysql/*
    
    umount /cat
    rm -fr /cat
    rm -fr file1
    
    echo "Cacitez已经卸载完毕"
}

##DNS 配置

##虚拟主机配置

myvhost() {

echo "开始配置虚拟主机"
cat << EOF > /etc/httpd/conf.d/host.conf
NameVirtualHost 10.249.17.52:80
<VirtualHost 10.249.17.52:80>
    DocumentRoot /var/www/html
    ServerName cacit.corp.anjuke.com
</VirtualHost>
EOF
echo "虚拟主机配置完成"

}

##启动服务

myserver () {

for ser
do
	service $ser restart  &>/dev/null
	echo "$ser 服务已经启动成功"
done

echo "CacitEZ 已经安装完成，请在浏览器中输入本机IP地址进行测试"

}
