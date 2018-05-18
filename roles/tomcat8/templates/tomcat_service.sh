#!/bin/bash
############################################################
## THIS FILE IS MANAGED BY ANSIBLE - DO NOT MANUALLY EDIT ##
############################################################
#
# GTA - custom tomcat start / stop script
#
# chkconfig: - 80 20
#
### BEGIN INIT INFO
# Provides: {{ tomcat_major_version }}
# Required-Start: $network $syslog
# Required-Stop: $network $syslog
# Default-Start:
# Default-Stop:
# Description: GTA custom {{ tomcat_major_version }} start / stop script
# Short-Description: start and stop tomcat
### END INIT INFO

if [ $UID -ne 0 ]; then
	echo "Must be root to run this script."
	exit
fi

# Set environment
export JAVA_HOME={{ java_home }}
export PATH=${JAVA_HOME}/bin:${PATH}


TOMCAT_USER="${TOMCAT_USER:-tomcat}"
TOMCATBASE="/opt/{{ tomcat_major_version }}"
CATALINA_HOME="{{ tomcat_home }}"

# Create an array with the tomcat installs
INSTANCES=(`ls $TOMCATBASE | grep tc`)
INSTCOUNT={{ '${#INSTANCES[@]}' }}
INDEX=0

input_time=$2;
if [ "$input_time" == "" ]; then
input_time=20M
fi

MCAST_FF="";
# If working with TCn then set the variable
if [[ "$1" == *-* ]] ; then
	# Set tomcat number and path
  	N=$(echo $1 | awk -F 'tc' '{print $2}')
  	TCNPATH="$TOMCATBASE/tc${N}/bin/"
    TCN_PATH="$TOMCATBASE/tc${N}"

	if [ -f $TCNPATH/setenv.sh ]; then
		MCAST_FF=$(grep mcast_add $TCNPATH/setenv.sh|tr -d '"' |grep -v "#"|awk -F"addr=" '{print $2}');
	fi
	if [ ! -d "$TCNPATH" ]; then
		echo
		echo "* Tomcat instance $N does not exist *"
		echo
		exit 1
	fi
fi

RET_MCAST="";
if [ ! "$MCAST_FF" == "" ]; then
	RET_MCAST=" - [ MCAST_F_F = $MCAST_FF ] -";
fi

# Set hostname
HOST_NAME=(`hostname -s`)
TCNAPP=`ls ${TOMCATBASE}/tc${N}/webapps/*.war`
function apps() { 
  for names in $TCNAPP; do 
	APPNAME=`echo ${names##*/}`; 
	lastupdated=`stat $names |grep Mod|awk -F"Modify:" '{print $2 " "$3}'|awk -F"." '{print $1}'`
	processid=$(pgrep -u tomcat -f $(basename $0)/tc$N)
	if [ "$processid" == "" ]; then
		 if [[ $action =~ stop ]]; then
			echo "$APPNAME - not found running - $RET_MCAST EXITING"
			exit 1;
		else
			echo -n " -  [ $APPNAME ] - $RET_MCAST"
		fi
	else
		multicast=$(/usr/sbin/lsof -P -p $processid|grep UDP|awk '{print $NF}'|grep 228);
 		if [ "$multicast" == "" ]; then
 			mcast=" [ RUNNING  - MULTICAST: {not found} ] - "
 		else
 	 		mcast=" [ RUNNING - MULTICAST: $(echo $multicast) ] - "
 		fi

		ctime=$((`date +%s`  - `stat -t /proc/$processid | awk '{print $14}'`))
		echo ": $ctime :"
		if [ $ctime -lt 86400 ]; then
			if [ $ctime -le 60 ]; then	
				runningtime="$ctime seconds"
			else
				if [ $ctime -lt 3600 ]; then
					ntime=`expr $ctime / 60`			
					runningtime="$ntime minutes"
				else
					ntime=`expr $ctime / 3600`
					runningtime="$ntime hours"
				fi
			fi
		else
		 	ntime=`expr $ctime / 86400`
                 	runningtime="$ntime days"
		fi
		rtime="Running time: $runningtime"
		if [[ $action =~ start ]]; then
			echo "Already running $APPNAME -- $RET_MCAST -- $mcast --  Last modified: $lastupdated  $rtime ] - EXITING SCRIPT"
			exit 1
		else
			echo -n " - [ $APPNAME -- $RET_MCAST -- $mcast -- Last modified: $lastupdated  $rtime  ---> $action ] - " ; 
		fi
	fi
   done;
echo
}

##############################
# Define functions
startAll() {
	echo "Starting All Tomcats"
	# Correct ownership - just in case
	chown -Rh tomcat. $TOMCATBASE
	while [ "$INDEX" -lt "$INSTCOUNT" ] ; do
		#su - $TOMCAT_USER -c "$TOMCATBASE/${INSTANCES[$INDEX]}/bin/catalina.sh start"
		su - $TOMCAT_USER -c "CATALINA_BASE=$TOMCATBASE/${INSTANCES[$INDEX]} ${CATALINA_HOME}/bin/catalina.sh start"
		let "INDEX++"
		echo Delay 5 before next one....
		sleep 3s
	done
}

startTCN() {
	echo -n "Starting TC$N -- ";
	action="start"
	apps;
	echo "If this is incorrect press CTRL+C to cancel within 3 seconds !!"
	sleep 3s
	# Correct ownership - just in case
	chown -Rh tomcat. $TCNPATH
	#su - $TOMCAT_USER -c "$TCNPATH/catalina.sh start"
	su - $TOMCAT_USER -c "CATALINA_BASE=$TCN_PATH ${CATALINA_HOME}/bin/catalina.sh start"
}

stopAll() {
	echo "Stopping All Tomcats"
	c=0;
	while [ "$INDEX" -lt "$INSTCOUNT" ] ; do
		((c++));
		if [[ $ce -le 1 ]]; then
                        nohup /sbin/service nagalert stop $input_time >/dev/null 2>&1 &
                fi

		#su - $TOMCAT_USER -c "$TOMCATBASE/${INSTANCES[$INDEX]}/bin/catalina.sh stop"
		su - $TOMCAT_USER -c "CATALINA_BASE=$TOMCATBASE/${INSTANCES[$INDEX]} ${CATALINA_HOME}/bin/catalina.sh stop"
		let "INDEX++"
		sleep 2s
	done

#disable forced kill for RM application 
HOST_NAME=(`hostname -s`) 
if [[ ! $HOST_NAME =~ rm$ ]]; then 
        echo Checking tomcat is stopped... 
        if [ "$(pgrep java | wc -l)" -gt "0" ] ; then 
               sleep 10s 
               PID=$(ps -ef | grep java | grep tc | awk '{print $2}') 
               if [ -n "$PID" ] ; then 
                      echo Waited 10 seconds - killing all TCn java 
                      echo $PID | xargs kill -9 
               fi 
        fi 
fi 
} 


stopTCN() {
	echo -n "Stopping TC$N -- " 
	action="stop"
	apps;
	echo "If this is incorrect press CTRL+C to cancel within 3 seconds !!"
        sleep 3s

	if [ -f /etc/init.d/nagalert ]; then
                nohup /sbin/service nagalert stop $input_time >/dev/null 2>&1 &
	fi

	#su - $TOMCAT_USER -c "$TCNPATH/catalina.sh stop"
	su - $TOMCAT_USER -c "CATALINA_BASE=${TCN_PATH} ${CATALINA_HOME}/bin/catalina.sh stop"
        echo Checking tomcat is stopped... and waiting 10 seconds 
	sleep 10s
#disable forced kill for RM application
HOST_NAME=(`hostname -s`)
if [[ ! $HOST_NAME =~ rm$ ]]; then
        echo Checking tomcat is stopped...
        if [ "$(pgrep java | wc -l)" -gt "0" ] ; then
                sleep 10s
                PID=$(ps -ef | grep java | grep tc${N} | awk '{print $2}')
              	if [ -n "$PID" ] ; then
			echo Waited 10 seconds - killing all TCn java
			echo $PID | xargs kill -9
		fi
	fi
fi

}



#####################################
# See how we were called
case "$1" in
	start)
		startAll
		;;
	start-tc$N)
		startTCN
		;;
	stop-tc$N)
		stopTCN
		;;
	stop)
		stopAll
		;;	
	restart)
		stopAll
		startAll
		;;
	restart-tc$N)
		stopTCN
		startTCN
		;;
	*)	
		echo "Usage: $0 {start|start-tcN|stop|stop-tcN|restart|restart-tcN}"
		exit 1
esac


