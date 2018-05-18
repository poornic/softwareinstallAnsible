#!/bin/sh
#------------------------------------------------
# Simple shell-script to run HornetQ standalone
#------------------------------------------------

# Set local IP
IPADDR=$(hostname -i)
OCT=$(echo $IPADDR | awk -F '.' '{print $4}')

export HORNETQ_HOME={{ hornetq_home }}
#mkdir -p ../logs

# By default, the server is started in the non-clustered standalone configuration

#if [ a"$1" = a ]; then CONFIG_DIR=$HORNETQ_HOME/config/stand-alone/non-clustered; else CONFIG_DIR="$1"; fi
if [ a"$1" = a ]; then CONFIG_DIR=$HORNETQ_HOME/config/stand-alone/clustered; else CONFIG_DIR="$1"; fi
if [ a"$2" = a ]; then FILENAME=hornetq-beans.xml; else FILENAME="$2"; fi

if [ ! -d $CONFIG_DIR ]; then
    echo script needs to be run from the HORNETQ_HOME/bin directory >&2
    exit 1
fi

RESOLVED_CONFIG_DIR=`cd "$CONFIG_DIR"; pwd`
export CLASSPATH=$RESOLVED_CONFIG_DIR:$HORNETQ_HOME/schemas/

# Use the following line to run with different ports
export CLUSTER_PROPS="-Djnp.port={{ hornetq_jnp_port }} -Djnp.rmiPort={{ hornetq_rmi_port }} -Djnp.host=${IPADDR} -Dhornetq.remoting.netty.host=${IPADDR} -Dhornetq.remoting.netty.port={{ hornetq_remoting_netty_port }}"

# {% if hornetq_clustered == 'false' %}
# export CLUSTER_PROPS="$CLUSTER_PROPS -Dhornetq.clustering.multicast.ip=231.7.7.${OCT}"
# {% endif %}

# properties specific to clustered mode
{% if hornetq_clustered == true %}
export CLUSTER_PROPS="$CLUSTER_PROPS -Dhornetq.clustering.multicast.ip={{ hornetq_multicast_ip }}"
{% else %}
export CLUSTER_PROPS="$CLUSTER_PROPS -Dhornetq.clustering.multicast.ip=231.7.7.${OCT}"
{% endif %}

export JMX_PROPS="-Dcom.sun.management.jmxremote.port={{ hornetq_jmxremote_port}} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

export JVM_ARGS="$CLUSTER_PROPS $JMX_PROPS -XX:+UseParallelGC -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -Xms{{ hornetq_Xms }} -Xmx{{ hornetq_Xmx }} -Dhornetq.config.dir=$RESOLVED_CONFIG_DIR -Djava.util.logging.manager=org.jboss.logmanager.LogManager -Dlogging.configuration=file://$RESOLVED_CONFIG_DIR/logging.properties -Djava.library.path=./lib/linux-i686:./lib/linux-x86_64"

# Set correct log dir path for log4j
export JVM_ARGS="$JVM_ARGS -Dhornetq.home=${HORNETQ_HOME}"

#export JVM_ARGS="-Xmx512M -Djava.util.logging.manager=org.jboss.logmanager.LogManager -Dlogging.configuration=$CONFIG_DIR/logging.properties -Dhornetq.config.dir=$CONFIG_DIR -Djava.library.path=. -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"

for i in `ls $HORNETQ_HOME/lib/*.jar`; do
	CLASSPATH=$i:$CLASSPATH
done

echo "***********************************************************************************"
echo "java $JVM_ARGS -classpath $CLASSPATH org.hornetq.integration.bootstrap.HornetQBootstrapServer $FILENAME"
echo "***********************************************************************************"
java $JVM_ARGS -classpath $CLASSPATH -Dcom.sun.management.jmxremote org.hornetq.integration.bootstrap.HornetQBootstrapServer $FILENAME
