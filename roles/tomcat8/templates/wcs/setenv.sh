############################################################
## THIS FILE IS MANAGED BY ANSIBLE - DO NOT MANUALLY EDIT ##
############################################################

# Set hostname
HOST_NAME=$(hostname -s)
# Set node number tc1 tc2 etc. NOTE - This method only allows for up to 9 TC instances
NODEN=$(echo $CATALINA_HOME | cut -c16)
# Value for JVM route
JVMR=$(echo $HOST_NAME | cut -c8-)

# Remote JMX connection
CATALINA_OPTS="-Dcom.sun.management.jmxremote.port=500$NODEN -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

# Memory / GC settings 
CATALINA_OPTS="$CATALINA_OPTS {{ jvm_args_mem }}"
CATALINA_OPTS="$CATALINA_OPTS {{ jvm_args_permsize }}"

# Define ports in server.xml. NOTE defaults below are 1 below standard ports... as will increment by TCn number
# Conflict with ajp port means shutdown default changed to start from 7990
JAVA_OPTS="$JAVA_OPTS -Dtomcat.shutdown.port=$[7990 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.http.port=$[8079 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.https.port=$[8442 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.ajp.port=$[8008 + $NODEN]"
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.jvm.route=${JVMR}-tc${NODEN}"
# Define TCP Clustering ports
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.tcpcluster.port=$[4000 + $NODEN]"

# Options for WCS
CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=UTF-8 -Dnet.sf.ehcache.enableShutdownHook=true -Djava.net.preferIPv4Stack=true -Duser.timezone=UTC"
CLASSPATH={{ wcs_home }}/bin:{{ java_home }}/lib/tools.jar

export JAVA_OPTS
export CATALINA_OPTS
export CLASSPATH
