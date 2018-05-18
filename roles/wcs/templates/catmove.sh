#!/bin/sh

echo "Importing with CatalogMover"

if [[ "$1" == "" ]] ; then
	echo " Empty catalogFile : exiting ... "
	exit 1
fi

echo "Ready to Import $1. Setting classpath "


PRE_CALL="java -classpath ./Sun/lib/ehcache-core-1.7.1_modified.jar:./Sun/lib/slf4j-api-1.7.5.jar:./Sun/lib/slf4j-log4j12-1.7.5.jar:./Sun/lib/log4j-1.2.17.jar:./cs-core.jar:./cs.jar:./cs-portlet.jar:./msxml.jar:./batch.jar:./logging.jar:./directory.jar:./wl6special.jar:./sserve.jar:./XMLBridge/xmles.jar:./xcelerate.jar:./basic.jar:./batch.jar:./visitor.jar:./gator.jar:./catalog.jar:./assetframework.jar:./cscommerce.jar:./commercedata.jar:./firstsite-filter.jar:./lucene-search.jar:./UI/ui.jar:./services-api/services-api-11.1.1.8.0.jar:./wem/wem-sso-api-cas-plugin-cs-11.1.1.8.0.jar:./wem/wem-sso-api-11.1.1.8.0.jar:./wem/wem-sso-api-cas-11.1.1.8.0.jar:./cs-cache-11.1.1.8.0.jar:./services-impl/services-impl-11.1.1.8.0.jar:./sites-security/sites-security-11.1.1.8.0.jar:./ucmintegration/ucm-poller-11.1.1.8.0.jar:./request-authenticator-11.1.1.8.0.jar:./Sun/jws/common/lib/commons-io-2.4.jar:./Sun/lib/jh.jar:./Sun/lib/looks-1.3.2.jar:./Sun/jws/common/lib/httpclient-4.1.2.jar:./Sun/jws/common/lib/httpcore-4.1.2.jar:./Sun/jws/common/lib/httpmime-4.1.2.jar:./Sun/jws/common/lib/apache-mime4j-0.5.jar:./Sun/jws/common/lib/commons-codec-1.7.jar:./Sun/jws/common/lib/commons-lang-2.5.jar:./Sun/jws/common/lib/sun-redistribs.jar:./Sun/jws/common/lib/commons-logging-1.1.1.jar:./Sun/jws/common/endorsed/dom.jar:./Sun/jws/common/endorsed/sax.jar:./Sun/jws/common/lib/jaxp-api.jar:./Sun/jws/common/endorsed/xercesImpl.jar:./Sun/jws/common/endorsed/xalan.jar:./Sun/lib/spring-beans-3.2.6.RELEASE.jar:./Sun/lib/spring-core-3.2.6.RELEASE.jar:./Sun/lib/spring-context-3.2.6.RELEASE.jar:./Sun/lib/spring-web-3.2.6.RELEASE.jar:./Sun/lib/spring-expression-3.2.6.RELEASE.jar:./wem/lib/cas-client-core-3.1.9.jar:./wem/lib/esapi-2.0.1.jar:./wem/webapp/WEB-INF/classes:./Sun/lib/log4j-1.2.17.jar:./cs-cache/lib/commons-fileupload-1.3.1.jar::./Sun/lib/jh.jar:./Sun/lib/looks-1.3.2.jar:./Sun/jws/common/lib/commons-codec-1.7.jar:./Sun/jws/common/lib/commons-lang-2.5.jar:./Sun/jws/common/lib/sun-redistribs.jar:./Sun/jws/common/lib/commons-logging-1.1.1.jar:./Sun/jws/common/endorsed/dom.jar:./Sun/jws/common/endorsed/sax.jar:./Sun/jws/common/lib/jaxp-api.jar:./Sun/jws/common/endorsed/XercesImpl.jar:./Sun/jws/common/endorsed/xalan.jar:./cs-core.jar:./cs-cache-11.1.1.8.0.jar:./cs.jar:./sserve.jar:./visitor.jar:./xcelerate.jar:./catalog.jar:./gator.jar:./cscommerce.jar:./CommerceConnector.jar:./gatorbulk.jar:./rules.jar:./msxml.jar:./flame.jar:./spark.jar:./commercedata.jar:./assetmaker.jar:./basic.jar:./sampleasset.jar:./FTLDAP.jar:./batch.jar:./logging.jar:./directory.jar:./wl6special.jar:./xmles.jar:./framework.jar:./firstsite-filter.jar:./firstsite-uri.jar:./wem/wem-sso-api-cas-plugin-cs-11.1.1.8.0.jar:./wem/wem-sso-api-cas-11.1.1.8.0.jar:./wem/cas-client-core-3.1.9.1.jar:./Sun/lib/spring-beans-3.2.6.RELEASE.jar:./Sun/lib/spring-core-3.2.6.RELEASE.jar:./Sun/lib/spring-context-3.2.6.RELEASE.jar:./Sun/lib/spring-web-3.2.6.RELEASE.jar:./Sun/lib/spring-expression-3.2.6.RELEASE.jar:./wem/wem-sso-api-11.1.1.8.0.jar:./Sun/lib/log4j-1.2.17.jar:./Sun/lib/ehcache-core-1.7.1_modified.jar:./Sun/lib/slf4j-log4j12-1.7.5.jar:./cs-cache/lib/commons-math-1.2.jar:./Sun/lib/slf4j-api-1.7.5.jar:./cs-cache/lib/commons-fileupload-1.3.1.jar:./sites-security-11.1.1.8.0.jar:./wem/lib/esapi-2.0.1.jar:. COM.FutureTense.Apps.CatalogMover"

HOST="{{ wcs_server }}"
PORT="{{ wcs_port }}"
cmd="$PRE_CALL -b http://$HOST:$PORT/cs/CatalogManager -u {{ wcs_admin_user }} -p {{ wcs_admin_password }} -x import -f $1"
echo Running $cmd
eval $cmd


exit 0
