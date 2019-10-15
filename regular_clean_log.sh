#!/bin/bash
##############################################################
#  脚本说明：kafka消息堆积日志定时清理
#  author  : weiy
#  date    : 2019-10-11
##############################################################

date_limit=3		###删除3天之内没有被更改的文件及文件夹;mmin是以分钟为单位，mtime是以天为单位


log_location=/sxapp/sxappopt/app/realtime/monitor/log/		###日志存放位置
$(find ${log_location} -mtime +${date_limit}|xargs rm -rf)