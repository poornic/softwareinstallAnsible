############################################################
## THIS FILE IS MANAGED BY ANSIBLE - DO NOT MANUALLY EDIT ##
############################################################

# Set hostname
HOST_NAME=$(hostname -s)
# Set node number tc1 tc2 etc. NOTE - This method only allows for up to 9 TC instances
NODEN=$(echo $CATALINA_HOME | cut -c16)
# Set node letter a, b, c, d etc.
NODEL=$(echo $HOST_NAME | cut -c10)
# Value for JVM route
JVMR=$(echo $HOST_NAME | cut -c8-)

# Remote JMX connection
CATALINA_OPTS="-Dcom.sun.management.jmxremote.port=500$NODEN -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

# Memory / GC settings 
CATALINA_OPTS="$CATALINA_OPTS {{ jvm_args_mem }}"
CATALINA_OPTS="$CATALINA_OPTS {{ jvm_args_permsize }}"
CATALINA_OPTS="$CATALINA_OPTS {{ jvm_args_res }}"
CATALINA_OPTS="$CATALINA_OPTS {{ jvm_args_gcthreads }}"

# Define ports in server.xml. NOTE defaults below are 1 below standard ports... as will increment by TCn number
# Conflict with ajp port means shutdown default changed to start from 7990
JAVA_OPTS="$JAVA_OPTS -Dtomcat.shutdown.port=$[7990 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.http.port=$[8079 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.https.port=$[8442 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.ajp.port=$[8008 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.jvm.route=${JVMR}-tc${NODEN}"
# Define TCP Clustering ports
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.tcpcluster.port=$[4000 + $NODEN]"

# External configuration location. NOTE - the app will append appname i.e. GS / GCPRICE to the end of this path
#CONFIGLOC="$CATALINA_HOME/shared/classes/META-INF/resources"
CONFIGLOC="$CATALINA_HOME/conf"
JAVA_OPTS="$JAVA_OPTS -DCONFIGLOC=$CONFIGLOC"

# Print GC 
JAVA_OPTS="$JAVA_OPTS -verbose:gc"
JAVA_OPTS="$JAVA_OPTS -Xloggc:$CATALINA_HOME/logs/gc.log"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDetails"
JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDateStamps"

JAVA_OPTS="$JAVA_OPTS -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:CMSInitiatingPermOccupancyFraction=70"

export JAVA_OPTS
export CATALINA_OPTS
