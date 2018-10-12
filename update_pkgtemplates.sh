#!/bin/bash

for i in cog_packages pub_packages lasjars jarlist solr_jars; do
    cp $i $i.tmpl;
done
