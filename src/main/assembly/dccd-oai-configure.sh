#!/usr/bin/env bash

#
# This postinstall script performs many of the steps necessary to install and configure
# the instructure for the DCCD web server software.
# The numbered steps match the manual installation steps described in the Github INSTALL.md file:
# https://github.com/DANS-KNAW/dccd-webui/blob/master/INSTALL.md
#
# @author Peter Brewer (p.brewer@ltrr.arizona.edu)


################################
# Functions
################################

# Helper function that asks user to define a password, then checks it with a repeat
# Call it with the name of the variable that you would like the new password stored
# inside e.g.:
# Param 1 = Variable into which the password should go
# Param 2 = The question to ask
#   
function getNewPwd()
{
	local __resultvar=$1
	
	pwd1=$(whiptail --passwordbox "$2" 8 70 --backtitle "DCCD Server Configuration Wizard" --title "$1" 3>&1 1>&2 2>&3)                                                                 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		pwd2=$(whiptail --passwordbox "Confirm password for $1" 8 70 --backtitle "DCCD Server Configuration Wizard" --title "$1" 3>&1 1>&2 2>&3)
		if [ $exitstatus != 0 ]; then
			clear
			exit 1
		fi
	else
		clear
	    exit 1
	fi
   
    # Check both passwords match
    if [ $pwd1 != $pwd2 ]; then    	
       showMessage "Error - passwords do not match!  Please try again..."
       getNewPwd "$1" "$2"
    else
       eval $__resultvar="'$pwd1'"
    fi
}

function getExistingPwd()
{
	local __resultvar=$1
	
	pwd1=$(whiptail --passwordbox "$2" 8 70 --backtitle "DCCD Server Configuration Wizard" --title "$1" 3>&1 1>&2 2>&3)                                                                 
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		eval $__resultvar="'$pwd1'"
	else
		clear
	    exit 1
	fi
   
    
}

#
# Simply display message
# Param 1 = Message
#
function showMessage()
{
	whiptail --backtitle "DCCD Server Configuration Wizard" --msgbox "$1" 10 70
	clear
}



#########################################
# Check if we're being run by root/sudo 
#########################################
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run by root or with sudo privileges"
	exit 1
fi

#
# Ask for passwords
#
getNewPwd dccd_oai "Create new password for dccd_oai:"
getExistingPwd fedoraAdmin "Enter the existing Fedora Admin password:"

#
# Create OAI database and database user
#
cp /opt/dccd/oai/create-oai-db.sql.orig /opt/dccd/oai/create-oai-db.sql
sed -i -e 's?###Fill-In-proai-Password###?'$dccd_oai'?' /opt/dccd/oai/create-oai-db.sql
su - postgres -c "psql -U postgres < /opt/dccd/oai/create-oai-db.sql"
#rm /opt/dccd/oai/create-oai-db.sql


#
# Set up the proai.properties file
#
mkdir -p /opt/dccd/oai/WEB-INF/classes/
cp /opt/dccd/oai/proai.properties.orig /opt/dccd/oai/WEB-INF/classes/proai.properties
sed -i -e 's?###Fill-In-proai-Password###?'$dccd_oai'?' /opt/dccd/oai/WEB-INF/classes/proai.properties
sed -i -e 's?###Fill-In-fedoraAdmin-Password###?'$fedoraAdmin'?' /opt/dccd/oai/WEB-INF/classes/proai.properties

#
# Replace proai.properties stub in war with our configured file
#
cd /opt/dccd/oai/
jar -uf /opt/dccd/dccd-oai.war WEB-INF/classes/proai.properties
#rm -rf /opt/dccd/oai/WEB-INF

#
# Make data folder and change it's ownership
mkdir /data/proai
chown -R tomcat:tomcat /data/proai

#
# Deploy war
#
cp /opt/dccd/oai/dccd-oai.xml /usr/share/tomcat6/conf/Catalina/localhost/

#
# Reload tomcat to start it
#
service tomcat6 force-reload

