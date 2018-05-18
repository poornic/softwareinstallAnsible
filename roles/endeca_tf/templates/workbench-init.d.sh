#!/bin/sh
#
# Oracle Endeca Tools Service
#
# chkconfig: 35 95 20
# description: Oracle Endeca Tools Service (Workbench)
#
################################################################################
#
# This is an example init.d service script for running Workbench automatically
# on Linux systems that support 'chkconfig'. The following steps will help you
# install Workbench as an automatic service.
#
# NOTE: Your Linux system must support 'chkconfig' for the following procedure.
#
# 1) Edit the ENDECA_TOOLS_ROOT variable (below) to match your installation
#    directory for the Endeca 'ToolsAndFrameworks' module. For example:
#
#      ENDECA_TOOLS_ROOT=/opt/endeca/ToolsAndFrameworks/VERSION
#
ENDECA_TOOLS_ROOT={{ endeca_home }}/ToolsAndFrameworks/{{ endeca_tf_version }}
#
# 2) Edit the ENDECA_USER (below) to match the system user account that you
#    want Workbench to run under. For example:
#
#      ENDECA_USER=endeca
#
ENDECA_USER={{ app_user }}
#
# 3) Make sure that the ENDECA_USER has execute privileges for files in the
#    following directories:
#
#      ${ENDECA_TOOLS_ROOT}/server/bin
#      ${ENDECA_TOOLS_ROOT}/server/apache-tomcat-${VERSION}/bin
#      ${JAVA_HOME}/bin
#
# 4) Review the chkconfig header at the top of this file to make sure it has
#    the appropriate runlevels, start priority, and stop priority for Workbench.
#    Consult the documention for your Linux system to understand these settings.
#
# 5) At a command prompt, switch to the root user. For example:
#
#      $ su
#
# 6) At a command prompt, copy your edited version of this file to /etc/init.d/workbench.
#    For example:
#
#      $ cp workbench-init.d.sh /etc/init.d/workbench
#
# 7) At a command prompt, run chkconfig to add the workbench service. For example:
#
#      $ /sbin/chkconfig --add workbench
#
################################################################################
# DO NOT EDIT BELOW THIS LINE
################################################################################

usage() {
  echo "Usage: ${0} (start|stop|status)"
  echo ""
  echo "  start   - starts Workbench as a background process"
  echo "  stop    - stops Workbench"
  echo "  status    - status Workbench"
  echo ""
}

case "${1}" in
  start)
    /bin/su - "${ENDECA_USER}" -c "${ENDECA_TOOLS_ROOT}/server/bin/startup.sh"
    ;;
  stop)
    /bin/su - "${ENDECA_USER}" -c "${ENDECA_TOOLS_ROOT}/server/bin/shutdown.sh"
    ;;
  status)
    OLDPID=`/usr/bin/pgrep -f ToolsAndFrameworks`
    if [ "$OLDPID" != "" ]; then
                /bin/echo "ToolsAndFrameworks is running (pid: $OLDPID)"
                 exit 0
        else
                /bin/echo "ToolsAndFrameworks is stopped"
                 exit 1
        fi
   ;;
  *)
    usage
    exit 2
esac

exit $?
