#!/bin/bash

for i in cog_packages pub_packages lasjars jarlist solr_jars; do
    sort $i > $i.tmpl;
done
