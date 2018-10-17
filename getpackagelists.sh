#!/bin/bash

cd /usr/local/las-esgf && find . -name '*.jar' >/root/lasjars
cd /usr/local/tomcat/webapps && find . -name '*.jar' >/root/jarlist
cd /usr/local/solr && find . -name '*.jar' >/root/solr_jars
export LD_LIBRARY_PATH=/opt/esgf/python/lib:/opt/esgf/python/lib/python2.7:/opt/esgf/python/lib/python2.7/site-packages/mod_wsgi/server
/usr/local/cog/venv/bin/pip freeze >/root/cog_packages
source /usr/local/conda/bin/activate esgf-pub
pip freeze >/root/pub_packages
cd /root
/usr/local/bin/esg-node --version >esgf_version
for i in cog_packages pub_packages lasjars jarlist solr_jars esgf_version; do
    touch $i;
done
tar -czf packagelists.tgz cog_packages pub_packages lasjars jarlist solr_jars esgf_version
rm -f cog_packages pub_packages lasjars jarlist solr_jars esgf_version
