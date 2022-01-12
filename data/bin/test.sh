#!/bin/bash -e
###################################################################
#
# Copyright (C) 2010 - 2021 Xilinx, Inc.  All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
###################################################################




# testname is always provided, since this is set by snapcraft.yaml
testname=$1

# All of the apps need 3 additional positional arguments at the start: sample name, model name, and image name, image list, or camera index


sample=$2
model=$3
arg3=$4

"$SNAP"/model_check.sh $model $sample
export VAI_LIBRARY_MODELS_DIR=$SNAP_USER_DATA/models
"$SNAP"/bin/test_${testname}_${sample} $model $arg3
