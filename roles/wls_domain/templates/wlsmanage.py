###########################################################
## THIS FILE IS MANAGED BY ANSIBLE - DO NOT MANUALLY EDIT ##
###########################################################

# WLST script to manage servers via NodeManager

domain='{{ domain_name }}'
adminUser='{{ app_user }}'
adminPW='{{weblogic_password }}'
domainDir='{{ domain_home }}'
nmType='{{ nm_type }}'
nmAddress='{{ server_name }}'
nmPort={{ nm_port }}
weblogicConnectURL='t3://' + nmAddress + ':' + str(nmPort)
nmDir=domainDir + '/nodemanager'
def connectToNM():
	try:
		nmConnect(adminUser,adminPW,nmAddress,nmPort,domain,domainDir,nmType)
	except:
		print 'Cannot connect to NodeManager.'
		sys.exit(1)

def enrollToNM():
	try:
		connect(adminUser,adminPW,weblogicConnectURL)
		nmEnroll(domainDir,nmDir)
	except:
		print 'Cannot enroll with NodeManager.'
		sys.exit(1)

def srvStatus(srv):
	try:
		return nmServerStatus(srv)
	except:
		print 'Cannot get server status.'
		sys.exit(1)

def srvStart(srv):
	try:
		nmStart(srv)
	except:
		print 'Cannot start server.'
		sys.exit(4)

def srvStop(srv):
	try:
		nmKill(srv)
	except:
		print 'Cannot stop server.'
		sys.exit(5)

# MAIN

# check arguments are fine
if len(sys.argv) <> 3:
	print 'Usage: java weblogic.WLST ' + sys.argv[0] + ' <server> start | stop | status'
	sys.exit(1)

# set arguments
srvName=sys.argv[1]
srvOp=sys.argv[2]

# connect to NodeManager
connectToNM()

if srvOp == 'status':
	srvStatus(srvName)

elif srvOp == 'start':
	srvStart(srvName)

elif srvOp == 'stop':
	srvStop(srvName)

else:
	print 'Usage: java weblogic.WLST ' + sys.argv[0] + ' <server> start | stop | status'
	sys.exit(1)

# disconnect from NodeManager
nmDisconnect()
sys.exit(0)
