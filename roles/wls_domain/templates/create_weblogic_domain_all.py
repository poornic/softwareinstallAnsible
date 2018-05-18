###########################################################
## THIS FILE IS MANAGED BY ANSIBLE - DO NOT MANUALLY EDIT #
###########################################################

# Script to create WebLogic domain containing ATG and Coherence servers

def loadPropertiesAsMap(filepath):
    retmap = {}
    lines = open(filepath, 'r').readlines()
    for line in lines:
        if line.strip().startswith('#') or line.strip() == '':
            # skip blank or comment lines
            continue
        else:
            if '=' in line:
                (key, value) = line.strip('\r\n').split("=", 1)
                retmap[key] = value
    return retmap

def submap(map, recursive=True):
    retmap = {}
    for (key, value) in map.items():
        if '.' in key:
            (sublkey, subrkey) = key.split('.', 1)
            if not sublkey in retmap:
                retmap[sublkey] = {}
            retmap[sublkey][subrkey] = value
        else:
            retmap[key] = value
    if recursive:
        for (key, value) in retmap.items():
            if hasattr(value, 'keys'):
                retmap[key] = submap(value)
    return retmap

def createMachine(cfgmap):
    machineName = cfgmap['machinename']
    machineAddr = cfgmap['addr']
    machinePort = cfgmap['port']
    cd('/')
    machineMB = create(machineName, 'Machine')
    cd('/Machine/%s' % (machineName))
    nodemanagerMB = create(machineName, 'NodeManager')
    nodemanagerMB.setDebugEnabled(False)
    nodemanagerMB.setListenAddress(machineAddr)
    nodemanagerMB.setListenPort(int(machinePort))
    cd('/Machine/' + machineName + '/NodeManager/' + machineName)
    set('ListenAddress', cfgmap['addr'])
    set('NMType', 'SSL')
    print "Machine: " + machineName
    print "Machine listen address: " + machineAddr

def createCluster(cfgmap):
    clusterName=cfgmap['clustername']
    create(clusterName, 'Cluster')
    print "Cluster: " + clusterName

def createServer(cfgmap):
    serverName = cfgmap["servername"]
    print 'Creating WebLogic server ' + serverName
    cd("/")
    serverCMO = create(serverName, "Server")
    cd('/Servers/' + serverName)
    print 'LISTENADDR = ' + cfgmap["listenaddr"]
    print 'LISTENPORT = ' + cfgmap["listenport"]

#    serverCMO.setListenAddress(cfgmap["listenaddr"])
#    serverCMO.setListenPort(int(cfgmap["listenport"]))
    set('ListenAddress','')
    set('ListenPort',int(cfgmap["listenport"]))

    if 'cluster' in cfgmap:
        clusterName = cfgmap['cluster']
        machineName = cfgmap['machine']
        cd('/Servers/' + serverName)
        assign('Server', serverName, 'Cluster', clusterName)
        assign('Server', serverName, 'Machine', machineName)
        create(serverName, 'ServerStart')
        cd('ServerStart/'+serverName)
        set ('ClassPath', cfgmap["classpath"])
        set ('Arguments', cfgmap["startargs"])
    print "Server: " + serverName
    updateDomain()

def createHornetQJMS(cfgmap):
    moduleName = cfgmap['modulename']

    # Create the JMS module
    cd('/')
    jmsModuleMB = create(moduleName, 'JMSSystemResource')
    cd('/JMSSystemResource/' + moduleName + '/JmsResource/NO_NAME_0')
    for target in cfgmap["target"].split(','):
        assign('JMSSystemResource', moduleName, 'Target', target)
    print "JMS module: " + moduleName

    # Create the JMS foreign server
    foreignServerName = cfgmap['servername']
    jmsConnectionFactory = cfgmap['factory-name']
    jmsConnectionFactoryLocalJNDI = cfgmap['factory-local-jndi']
    jmsConnectionFactoryRemoteJNDI = cfgmap['factory-remote-jndi']
    jmsForeignServerMB = create(foreignServerName, 'ForeignServer')
    cd('/JMSSystemResources/' + moduleName + '/JmsResource/NO_NAME_0/ForeignServers/'+foreignServerName)
    set('InitialContextFactory', 'org.jnp.interfaces.NamingContextFactory')
    set('ConnectionURL', cfgmap['connection-url'])
    cmo.setDefaultTargetingEnabled(true)
    print "JMS foreign server: " + foreignServerName

    # Create the foreign JMS destinations
    jmsDestinationsKeys = props["wls"]["hornetqdest"]
    for jmsKey in jmsDestinationsKeys:
        jmsMap = props["wls"]["hornetqdest"][jmsKey]
        jmsForeignDestination = jmsMap["name"]
        cd('/JMSSystemResources/' + moduleName + '/JmsResource/NO_NAME_0/ForeignServers/'+ foreignServerName)
        jmsForeignDestinationMB = create(jmsForeignDestination, 'ForeignDestination')
        cd('/JMSSystemResources/' + moduleName + '/JmsResource/NO_NAME_0/ForeignServers/'+ foreignServerName + '/ForeignDestinations/' + jmsForeignDestination)
        cmo.setLocalJNDIName(jmsMap['local-jndi'])
        cmo.setRemoteJNDIName(jmsMap['remote_jndi'])
        print 'JMS foreign destination: ' + jmsForeignDestination

    # Create the foreign connection factory
    cd('/JMSSystemResources/' + moduleName + '/JmsResource/NO_NAME_0/ForeignServers/'+ foreignServerName)
    jmsConnectionFactoryMB = create(jmsConnectionFactory, 'ForeignConnectionFactory')
    cd('/JMSSystemResources/' + moduleName + '/JmsResource/NO_NAME_0/ForeignServers/'+ foreignServerName + '/ForeignConnectionFactories/' + jmsConnectionFactory)
    cmo.setLocalJNDIName(jmsConnectionFactoryLocalJNDI)
    cmo.setRemoteJNDIName(jmsConnectionFactoryRemoteJNDI)
    print 'JMS foreign connection factory: ' + jmsConnectionFactory

def createDataSource(cfgmap):
    resourceName = cfgmap["jdbcname"]
    cd('/')
    jdbcMB = create(resourceName, 'JDBCSystemResource')
    cd('/JDBCSystemResource/' + resourceName + '/JdbcResource/' + resourceName)
    jdbcParamsMB = create(resourceName + 'DriverParams', 'JDBCDriverParams')
    cd('JDBCDriverParams/NO_NAME_0')
    set('DriverName', cfgmap["driver"])
    set('URL', cfgmap["url"])
    set('PasswordEncrypted', cfgmap["password"])
    create(resourceName + 'Props','Properties')
    cd('Properties/NO_NAME_0')
    create('user', 'Property')
    cd('Property/user')
    cmo.setValue(cfgmap["user"])

    # Create the JNDI for the datasource
    cd('/JDBCSystemResource/' + resourceName + '/JdbcResource/' + resourceName)
    create(resourceName + 'DataSourceParams', 'JDBCDataSourceParams')
    cd('JDBCDataSourceParams/NO_NAME_0')
    set('JNDIName', java.lang.String(cfgmap["jndi"]))

    # Create the Test Table
    cd('/JDBCSystemResource/' + resourceName + '/JdbcResource/' + resourceName)
    create(resourceName + 'ConnectionPoolParams', 'JDBCConnectionPoolParams')
    cd('JDBCConnectionPoolParams/NO_NAME_0')
    set('TestTableName','SQL SELECT 1 FROM DUAL')
    # Set Maximum Capacity for the connection pool
    cmo.setMaxCapacity(int(cfgmap["maxcapacity"]))

    # Target the datasource
    for target in cfgmap["target"].split(','):
        assign('JDBCSystemResource', resourceName, 'Target', target)

    print "JDBC resource: " + resourceName

def createCoherenceCluster(cfgmap):
    clstrName = cfgmap['clustername']
    print "Creating a Coherence cluster: " + clstrName
    cd("/")
    create(clstrName, 'CoherenceClusterSystemResource')
    print "Successfully created the Coherence Cluster."

    # Configure the Coherence Cluster
    print "Configuring the Coherence Cluster: " + clstrName
    cd('CoherenceClusterSystemResource/' + clstrName + '/CoherenceResource/' + clstrName + '/CoherenceClusterParams/NO_NAME_0')
    set('ClusteringMode', 'unicast')
    {% if weblogic_major_version >= 12.2 %}
    # This is for Weblogic 12.2.1.2
    set('ClusterListenPort', int(cfgmap['unicast-port']))
    {% else %}
    # This is for Weblogic 12.1.2
    set('UnicastListenPort', int(cfgmap['unicast-port']))
    {% endif %}

    set('UnicastPortAutoAdjust', 'true')

    # Assign the Coherence Cluster to a WebLogic Cluster
    wlsClusterName = cfgmap['wls-clustername']
    print 'Assigning the Coherence Cluster %s to WebLogic Cluster %s' % (clstrName, wlsClusterName)
    assign('Cluster', wlsClusterName, 'CoherenceClusterSystemResource', clstrName)
    cd('/CoherenceClusterSystemResource/' + clstrName)
    set('Target', wlsClusterName)
    print 'Successfully assigned Coherence Cluster %s to WebLogic Cluster %s' % (clstrName, wlsClusterName)
    print 'Finished creating Coherence cluster: ' + clstrName

def createCoherenceServer(cfgmap):
    svrName = cfgmap['servername']
    print "Creating Coherence Server: " + svrName
    # Configure Coherence
    print 'Configuring the Coherence server: ' + svrName
    cd('/Server/' + svrName)
    create('member_config', 'CoherenceMemberConfig')
    cd('CoherenceMemberConfig/member_config')
    set('LocalStorageEnabled', cfgmap['localstorage-enabled'])

def createDynamicCoherenceServers():
    cohDynaServerMachines         = props['coh']['dynaservers']['machines']
    cohDynaServerCount            = int(props['coh']['dynaservers']['count'])
    cohDynaServerPrefix           = props['coh']['dynaservers']['prefix']
    cohDynaServerListenAddrStart  = props['coh']['dynaservers']['listenaddr-start']
    cohDynaServerWeblogicCluster  = props['coh']['dynaservers']['wls-cluster']
    cohDynaServerCoherenceCluster = props['coh']['dynaservers']['coh-cluster']
    cohDynaServerStartArgs        = props['coh']['dynaservers']['startargs']
    cohDynaServerClasspathArgs    = props['coh']['dynaservers']['classpath']

    print 'Dynamic Coherence Machines:          %s' % (cohDynaServerMachines)
    print 'Dynamic Coherence Count:             %s' % (cohDynaServerCount)
    print 'Dynamic Coherence Prefix:            %s' % (cohDynaServerPrefix)
    print 'Dynamic Coherence WebLogic Cluster:  %s' % (cohDynaServerWeblogicCluster)
    print 'Dynamic Coherence Coherence Cluster: %s' % (cohDynaServerCoherenceCluster)

    machineArr = cohDynaServerMachines.split(',')
    for i in range(len(machineArr)):
        cohDynaMachine = machineArr[i]
        # for cohDynaMachine in machineArr:
        cohMachineName = cohDynaMachine.strip()
        print 'Creating dynamic Coherence servers for machine: ' + cohMachineName
        # Create the dictionary with for the ser
        for j in range(cohDynaServerCount):
            cohServerName = '%s%03d' % (cohDynaServerPrefix, (i * cohDynaServerCount) + j + 1)
            print 'cohServerName: ' + cohServerName

            # create the WLS server
            wlsServerConfig = dict()
            wlsServerConfig['servername'] = cohServerName
            wlsServerConfig['listenaddr'] = props['coh']['dynaservers'][cohMachineName]['wls-listenaddr']
            wlsServerConfig['listenport'] = '%s' % (int(cohDynaServerListenAddrStart) + j)
            wlsServerConfig['cluster'] = cohDynaServerWeblogicCluster
            wlsServerConfig['machine'] = cohMachineName
            wlsServerConfig['startargs'] = cohDynaServerStartArgs
            wlsServerConfig['classpath'] = cohDynaServerClasspathArgs

            # TODO: process the JVM args to allow for dynamic replacement
            print wlsServerConfig
            createServer(wlsServerConfig)

            # create the Coherence server
            cohServerConfig = dict()
            cohServerConfig['servername'] = cohServerName
            cohServerConfig['coherence-cluster'] = cohDynaServerCoherenceCluster
            cohServerConfig['localstorage-enabled'] = 'true'
            print cohServerConfig
            createCoherenceServer(cohServerConfig)

# MAIN

if len(sys.argv) != 2:
    print 'Usage: java weblogic.WLST %s <propertiesfile>'
    sys.exit(1)

# Load Properties into Python map
props = loadPropertiesAsMap(sys.argv[1])

# Create map of maps based on property keys
props = submap(props)

# Read the standard WLS template
readTemplate('/opt/oracle/middleware12c/wlserver/common/templates/wls/wls.jar')

# Set the Admin Server Port
cd ('Servers/AdminServer')
cmo.setListenPort(int(props["wls"]["admin"]["adminport"]))

# Set the admin password BEFORE we rename the domain
cd('/Security/base_domain/User/weblogic')
cmo.setPassword(props["wls"]["admin"]["password"])
setOption('OverwriteDomain', 'true')
cd("/")
cmo.setName(props['domain']['name'])
print '**** Creating WebLogic domain ****'
print 'Domain: ' + props['domain']['name']
domainDir = props["domain"]["home"] + "/" + props["domain"]["name"]

# Set production mode if specified
prodmode = props['domain']['production-mode']
if prodmode == "true":
    cmo.setProductionModeEnabled(True)

cd("/")

# Create the machines
machineKeys = props["wls"]["machines"]
for machineKey in machineKeys:
    createMachine(props["wls"]["machines"][machineKey])

# Create the Clusters
clusterKeys = props["wls"]["clusters"]["atg"]
for clusterKey in clusterKeys:
    createCluster(props["wls"]["clusters"]["atg"][clusterKey])

# Create the servers
serverKeys = props["wls"]["servers"]
for serverKey in serverKeys:
    createServer(props["wls"]["servers"][serverKey])

{% if include_coherence %}
# Create the Coherence clusters
cohClusterKeys = props['coh']['clusters']
for cohClusterKey in cohClusterKeys:
    createCoherenceCluster(props['coh']['clusters'][cohClusterKey])

# Create the Coherence servers
cohServerKeys = props['coh']['servers']
for cohServerKey in cohServerKeys:
    createCoherenceServer(props['coh']['servers'][cohServerKey])

# Create Coherence servers
createDynamicCoherenceServers()
{% endif %}

{% if include_fo or include_bo %}
# Create the JDBC resources
jdbcKeys = props["wls"]["jdbc"]
for jdbcKey in jdbcKeys:
    createDataSource(props["wls"]["jdbc"][jdbcKey])
{% endif %}

{% if include_bo %}
# Create the HornetQ JMS resources
createHornetQJMS(props["wls"]["hornetq"])
{% endif %}

# Write the domain configuration
print 'Domain directory: ' + domainDir
writeDomain(domainDir)
