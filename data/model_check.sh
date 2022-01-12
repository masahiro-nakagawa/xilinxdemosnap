#!/bin/bash
###################################################################
#
# Copyright (C) 2010 - 2021 Xilinx, Inc.  All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
###################################################################
# model_list.txt format: 
# 
# <sample app name> <model name> 
#
# Note: This script expects each model name to be listed only once
# in model_list.txt. 

DOWNLOAD_LOC=https://www.xilinx.com/bin/public/openDownload?filename=
DOWNLOAD_BOARDPART_ZCU10X="zcu102_zcu104-r1.3.1.tar.gz"
DOWNLOAD_BOARDPART_KV260="DPUCZDX8G_ISA0_B3136_MAX_BG2-1.3.1-r241.tar.gz"
FINGERPRINT_ZCU10X="0x1000020f6014407"
FINGERPRINT_KV260="0x1000020f6014406"

MODEL=$1
SAMPLE=$2

ERR=`show_dpu 2> /dev/null`
RET=$?
if [ $RET != 0 ] ; then
	echo ""
	echo "Error Reading DPU Fingerprint, make sure a bitstream is loaded with a valid DPU. "
	echo "This snap currently supports DPU configurations compatible with the v1.3.1 Model Zoo " 
	echo "models for the zcu102, zcu104, and KV260 boards."
	echo ""
	echo "Complatible fingerprints: "
	echo "  ZCU10x: ${FINGERPRINT_ZCU10X}"
	echo "  KV260: ${FINGERPRINT_KV260}"
	echo ""
	echo "If you have a valid DPU loaded and you're still seeing this message, make sure that" 
	echo "the assets content interface is connected to the to xlnx-config snap: "
	echo ""
	echo "sudo snap connect xlnx-vai-lib-samples:assets xlnx-config:assets"
	echo ""
	echo "Exiting"

	exit 1
fi

#Print the 9th value, and exit after first match
FINGERPRINT=`show_dpu | awk '{print $9; exit }'`

echo "Model Name: $MODEL"
echo "Sample Name: $SAMPLE"
echo "DPU Fingerprint: $FINGERPRINT"

if [ $FINGERPRINT == $FINGERPRINT_ZCU10X ] ; then
	echo "* Using zcu10x model"
	DOWNLOAD_BOARDPART=$DOWNLOAD_BOARDPART_ZCU10X
else 
	echo "* Using kv260 model"
        DOWNLOAD_BOARDPART=$DOWNLOAD_BOARDPART_KV260
fi

# Determine if the sample and model is available and compatible
#    * Match only against first and second words in the file, and
#    * Match the search value exactly, and print the line number of the match
#    * Use sed to strip off only the line number, return that in match
#    * if match is empty, exit
match=`awk '{print $1 $2}' $SNAP/model_list.txt |  grep -n -x ${SAMPLE}${MODEL} | sed -e 's/:.*//g'`
if  [ -z $match ]; then 
    echo "Please specify a valid combination of sample app and model"
    echo "Run xlnx-vai-lib-samples.info for a list of available sample apps an models"
    exit 1
fi



if [ ! -d "$SNAP_USER_DATA/models" ] ; then 
      echo "Creating $SNAP_USERl_DATA/models directory"
      echo "Additional models will be downloaded to this directory"
      mkdir $SNAP_USER_DATA/models
fi

if  [ -d "$SNAP_USER_DATA/models/$MODEL" ];  then
        echo "Downloaded model $MODEL found in $SNAP_USER_DATA"
    exit 0
 else
        # download to SNAP_USER_DATA, and use VAI_LIBRARY_MODELS_DIR
        # to point to the models
        echo "Model $MODEL is available for download"
        filename="${MODEL}-${DOWNLOAD_BOARDPART}"

        echo "Attempting to download model archive $filename"

        wget --no-config ${DOWNLOAD_LOC}${filename} -O  ${filename}

        tar -xzf $filename -C ${SNAP_USER_DATA}/models

        echo "Removing model archive $filename"

        rm $filename

        echo "Done!"
 fi



