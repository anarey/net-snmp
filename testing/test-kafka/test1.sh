HOME="/app"
TOPIC="rb_snmp"
NETSNMP_PATH_TEST=$HOME"/testing/test-kafka"
APP_SNMPTRAPD=$HOME"/apps/snmptrapd -Lf /var/log/snmptrapd.log -d -c /app/snmptrapd.conf"

echo "==============================================="
echo "NET-SNMP"
echo $APP_SNMPTRAPD
echo "==============================================="

export MIBS=ALL
export SNMPCONFPATH=/app/snmp.conf

cp -a /app/mibs /usr/local/share/snmp/

$APP_SNMPTRAPD

# kafkacat:

KAFKACAT_PATH="/kafkacat"
JSON_OUT=$NETSNMP_PATH_TEST'json_message1.log'

IP_KAFKA="172.16.238.11"

echo "------------------------------------------------------------------------"
sleep 5
echo "==============================================="
echo "Kafkacat. Get the json messages. output: 'json_out_kafka.log' "
echo $KAFKACAT_PATH/kafkacat -C -c 3 -o beggining -b $IP_KAFKA -t $TOPIC
echo "==============================================="
$KAFKACAT_PATH/kafkacat -C -c 3 -o beggining -b $IP_KAFKA -t $TOPIC > $JSON_OUT &


TRAP1="/app/apps/snmptrap -v 2c -c redborder localhost '' NET-SNMP-EXAMPLES-MIB::netSnmpExampleHeartbeatNotification netSnmpExampleHeartbeatRate i 123456"

TRAP2="/app/apps/snmptrap -v 1 -c redborder localhost '1.2.3.4.5.6' '192.193.194.193' 6 99 '55' 1.11.12.13.14.15  s 'teststring23w222'"

#$KAFKACAT_PATH/kafkacat -L -b $IP_KAFKA -t $TOPIC



#$TRAP1
echo "==============================================="
echo $TRAP2
echo "==============================================="
#$TRAP2
/app/apps/snmptrap -v 1 -c redborder localhost '1.2.3.4.5.6' '192.193.194.195' 6 99 '55' 1.11.12.13.14.15  s "teststring"

sleep 10

# Stop kafkacat
if ps aux | grep -v "grep" | grep "kafkacat" 1> /dev/null
then
    echo "kafkacat is running. Kill it."
    for i in `ps aux | grep -v "grep"|grep "kafkacat"|awk '{print $2}'|uniq`; do kill -SIGINT $i; done
else
   echo "kafkacat is stopped"
fi

## Check the json file send to kafka

# test4
PYCHECKJSON="/bin/checkjson.py"
JSON_CHECK_TEMPLATE="template-trap1.json"
#DEBUG=" -d"
DEBUG=""
echo "==============================================="
echo $PYCHECKJSON -t $FREERADIUS_PATH_TEST$JSON_CHECK_TEMPLATE -j $JSON_OUT$DEBUG
echo "==============================================="
#$PYCHECKJSON -t $FREERADIUS_PATH_TEST$JSON_CHECK_TEMPLATE -j $JSON_OUT$DEBUG

echo "======== /app/testing/test-kafkajson_message1.log"
cat /app/testing/test-kafkajson_message1.log

echo "= log = "
cat /var/log/snmptrapd.log
