#!/bin/bash
#backup mongodb's data, default is one day

start_date=$(date --date='1 day ago' +%F)
end_date=$(date +%F)
filename=mongodata_$start_date-$end_date
db_name=gcj-development
col_name=production_log

if [ -n "$1" ];then
  start_date=$1
fi

if [ -n "$2" ];then
  end_date=$2
fi

let "start_at=$(date --date=$start_date +%s) * 1000"
let "end_at=$(date --date=$end_date +%s) * 1000"

if [ -f $filename.json ];then
  rm $filename.json
fi

pid=`ps -ef |grep -v grep |grep mongod |sed -n '1P' |awk '{print $2}'`
if [[ -n $pid ]]; then
  mongoexport -d $db_name -c $col_name -q "{request_time:{'\\\$gte':new Date($start_at),'\\\$lt':new Date($end_at)}}" -o $filename.json
else
  exit 0
fi

if [ -f $filename.tar.gz ];then
  rm $filename.tar.gz
fi

if [[ -f $filename.json ]]; then
  tar czf $filename.tar.gz $filename.json
fi

if [[ -f $filename.json ]]; then
  rm $filename.json
fi
echo 'ok====----====ko'
