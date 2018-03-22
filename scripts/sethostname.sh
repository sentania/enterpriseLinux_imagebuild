#!/usr/bin/env bash


#We want to set a hostname that represents the build of this images
#partially this is to increase the auditibility of this image
#and partly to keep foreman from getting butt adauth_username_NMTEST
nmcli general hostname elbuild-$PACKER_BUILD_NAME
systemctl restart systemd-hostnamed
