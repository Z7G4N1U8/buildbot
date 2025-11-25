#!/bin/bash

# Increase System Limits
ulimit -n 65536
ulimit -S -n 65536

# Setup ccache
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

export USE_RBE=1                                      
export RBE_DIR="$HOME/.rbe"
export NINJA_REMOTE_NUM_JOBS=128

# BuildBuddy Connection Settings
export RBE_service="aosp.buildbuddy.io:443"
export RBE_use_rpc_credentials=false                   
export RBE_service_no_auth=true                       

# Unified Downloads/Uploads
export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true

# Execution Strategies
export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# Enable RBE for Specific Tools
export RBE_R8=1
export RBE_D8=1
export RBE_JAVAC=1
export RBE_JAR=1
export RBE_ZIP=1
export RBE_TURBINE=1
export RBE_SIGNAPK=1
export RBE_CXX_LINKS=1
export RBE_CXX=1
export RBE_ABI_LINKER=1
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# Resource Pools
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default
