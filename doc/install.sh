#!/bin/bash

. ./lib.sh

while : ;do
echo -e "\t*******自动化安装脚本******\t\t\n"
echo -e "\t1.自动安装CactiEZ\t\n"
echo -e "\t2.自动卸载CactiEZ\t\n"
echo -e "\t3.退出菜单\t\n"
read -p "你的选择是：" key
case $key in
	1)
        packgecheck httpd mysql mysql-server mysql-devel php php-mysql php-gd bind bind-chroot net-snmp net-snmp-devel net-snmp-utils
        sql
        cactiez
        myserver  httpd snmpd
        echo "按任意键返回菜单"
        read -n1
        continue
        ;;
        2)
        read -p "你真的要卸载吗(yes/no):" yo
        if [[ $yo == yes  ]]
        then
        packgedel
        delcat
        echo "按任意键返回菜单"
        read -n1
        continue
        else
        continue
        fi
        ;;
        3)
        exit
esac
done
