# What this is

`generate_esgfconf.sh` is a script file from the esgf_scanner repo which is used to generate as output, a configuration file for use with the [cvechecker tool](https://github.com/snic-nsc/cvechecker).   
The idea is to be able to auto-generate a manifest for each release, and use that an input to scan for known vulnerabilities.  When a reported vulnerability is studied and deemed to be addressed, it can then be muted, to prevent repeated notifications for the same issue.

# Cloning

- Clone this repo with the --recursive flag, as it checks out the cvechecker repository as a submodule. 

# Input files

- cog_packages, pub_packages, jarlist, esgf_manual, esgf_excludes
    - cog_packages and pub_packages are the output of a pip freeze, obtained from the CoG python (), and the esgfpub environment ()
    - jarlist is the output of a find command, looking for jar files in the tomcat webapps directory.
    - esgf_manual and esgf_excludes contains packages which are manually specified, and the only input files which are actually actively maintained in git; the remaining are meant to be dynamically generated/replaced with the latest available versions, prior to running `generate_esgfconf.sh`

# How to run

- For testing, simply execute firstuse.sh, which creates sample input files from the template files. After this, run generate_esgfconf.sh, to generate the esgf.conf file, which can then be used as the configuration file with cvechecker.

 
