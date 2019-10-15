#!/bin/bash
##############################################################
#  脚本说明：kafka消息堆积监控
#  author  : weiy
#  date    : 2019-10-11
##############################################################
day=$(date "+%Y%m%d")
datetime=$(date "+%F %H:%M:%I")

groups_config_file=/sxapp/sxappopt/app/realtime/monitor/config/kafka_groups_config.txt  ###消费组和appname的配置文件信息
monitor_log_file=/sxapp/sxappopt/app/realtime/monitor/log/monitor_flink_kafka_delay_${day}.txt	###监控日志文件
monitor_warn_file=/sxapp/sxappopt/app/realtime/monitor/warn.txt									###告警信息存放
tmp_file=/sxapp/sxappopt/app/realtime/monitor/tmp.txt											###临时文件，仅为存放临时结果
kafka_dir=/sxapp/sxappopt/hadoopclient/Kafka/kafka												###kafka的安装目录

#kerberos认证
kinit cdm_user<<EOF
Cdm@12345
EOF

lag_threshold=10000			###堆积消息数超过阈值则报警
bootstrapserver=10.7.9.11:21007		


#清空临时文件
>${tmp_file}

#line 即为kafka的消费组 appname
while read line || [[ -n ${line} ]];
do
        group_name=$(echo ${line}|awk -F ' ' '{print $1}')  ### 消费组名称
        app_name=$(echo ${line}|awk -F ' ' '{print $2}')     ### app名称
        echo "${datetime}|开始监控消费组|${group_name}">>${monitor_log_file}
        echo "${datetime}|运行的脚本是:" >>${monitor_log_file}
        echo "sh ${kafka_dir}/bin/kafka-consumer-groups.sh --bootstrap-server ${bootstrapserver} --describe --group ${group_name} --command-config ${kafka_dir}/config/consumer.properties" >>${monitor_log_file}
        #执行查看命令
        sh ${kafka_dir}/bin/kafka-consumer-groups.sh --bootstrap-server ${bootstrapserver} --describe --group ${group_name} --command-config ${kafka_dir}/config/consumer.properties 1>${tmp_file} 2>>${monitor_log_file}
        cat ${tmp_file}>>${monitor_log_file}
        echo "==================================================================================">>${monitor_log_file}
        #取到topic部分
        topics=($(awk -F ' ' '{print $1}' ${tmp_file}|grep -v TOPIC))
        #取到lag消息堆积部分,message_lag的格式为0 0 0 0每一个分区的堆积量是用空格分隔开的
        message_lag=($(awk -F ' ' '{print $5}' ${tmp_file}|grep -v LAG))
		length=${#message_lag[@]}
		max=${message_lag[0]}
		current_topic=${topics[0]}										
		for(( i=0;i<${#message_lag[@]};i++)) do
			if [ ${message_lag[i]} -gt ${max} ]
				then max=${message_lag[i]}
					 current_topic=${topics[i]}
			fi
				done;
		if [ ${max} -gt  ${lag_threshold} ]
                then
                        echo -e "${datetime}|kafka堆积警告|\033[31mapp_name : ${app_name}\033[0m|Topic : ${current_topic}|Group : ${group_name}|\033[31m该topic中消息堆积数为 : ${max}\033[0m">>${monitor_warn_file}
                        python /sxapp/sxappopt/app/realtime/monitor/sendmsg.py "测试消息！${datetime}|kafka堆积警告|app_name : ${app_name}|Topic : ${current_topic}|Group : ${group_name}|该topic中消息堆积数为 : ${max}"
        fi
done<$groups_config_file
