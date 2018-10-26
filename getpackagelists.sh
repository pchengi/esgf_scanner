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
cp /usr/local/solr/pre_replacement_solr_jarlist.txt .
cp /usr/local/solr/post_replacement_solr_jarlist.txt .
for i in cog_packages pub_packages lasjars jarlist solr_jars esgf_version pre_replacement_solr_jarlist.txt post_replacement_solr_jarlist.txt; do
    touch $i;
done
echo "# Tomcat Webapps" >manifest.md
echo "" >>manifest.md
cat jarlist >>manifest.md
echo "" >>manifest.md
echo "# Solr jars" >>manifest.md
echo "" >>manifest.md
cat solr_jars >>manifest.md
echo "" >>manifest.md
echo "# LAS jars" >>manifest.md
echo "" >>manifest.md
cat lasjars >>manifest.md
echo "" >>manifest.md
echo "# Cog Packages" >>manifest.md
echo "" >>manifest.md
cat cog_packages >>manifest.md
echo "" >>manifest.md
echo "# Publisher Packages" >>manifest.md
echo "" >>manifest.md
cat cog_packages >>manifest.md
echo "" >>manifest.md

tar -czf packagelists.tgz cog_packages pub_packages lasjars jarlist solr_jars esgf_version post_replacement_solr_jarlist.txt pre_replacement_solr_jarlist.txt manifest.md
rm -f cog_packages pub_packages lasjars jarlist solr_jars esgf_version pre_replacement_solr_jarlist.txt post_replacement_solr_jarlist.txt manifest.md
