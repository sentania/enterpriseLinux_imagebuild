# Script will register the system to the Satellite server specified and using the ORG and activation key.
# Variables are coming from the environment variables.

# Make sure we have all the information we need to completed the request.
if [ -z $KATELLO_HOSTNAME ]; then
	echo "Missing Vairable KATELLO_HOSTNAME"
	exit 1
elif [ -z $SATELLITE_ORG ]; then
	echo "Missing Vairable SATELLITE_ORG"
	exit 1
elif [ -z $SATELLITE_ACTIVATIONKEY ]; then
	echo "Missing Vairable SATELLITE_ACTIVATIONKEY"
	exit 1
fi

echo Sat. Hostname: $KATELLO_HOSTNAME
echo Organization: $SATELLITE_ORG
echo Activation Key: $SATELLITE_ACTIVATIONKEY

# remove all the repos from the /etc/yum.repos.d directory.
rm -f /etc/yum.repos.d/*
# First Set the host to get the Katello server from.
KATELLO_HOSTNAME="$KATELLO_HOSTNAME"

# Download and install the Katello certs
echo rpm -Uvh https://$KATELLO_HOSTNAME/pub/katello-ca-consumer-latest.noarch.rpm
wget --no-check-certificate https://$KATELLO_HOSTNAME/pub/katello-ca-consumer-latest.noarch.rpm -O /tmp/katello-ca-consumer-latest.noarch.rpm
rpm -Uvh /tmp/katello-ca-consumer-latest.noarch.rpm

# Register with the Katello using correct the activation key for a base build
echo subscription-manager register --org="$SATELLITE_ORG" --activationkey="$SATELLITE_ACTIVATIONKEY" --force
subscription-manager register --org="$SATELLITE_ORG" --activationkey="$SATELLITE_ACTIVATIONKEY"  --force
