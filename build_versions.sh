#!/bin/bash

# Create compaction directory, -p option makes it ignore if the directory already exists
mkdir -p compaction
mkdir -p filter_and_join

# Compaction options as parallel arrays (for compatibility with older bash versions)
compaction_keys=("logical" "smart")
compaction_values=("USE_NO_COMPACT" "USE_DYNAMIC_COMPACT")

# Project name - replace with your executable name
executables=("filter_and_join" "compaction")

for name in "${executables[@]}"; do
    for i in "${!compaction_keys[@]}"; do
        key="${compaction_keys[$i]}"
        value="${compaction_values[$i]}"
        
        # Build the version
        mkdir -p build-${key}
        cd build-${key}
        # Generate make files with the option enabled
        cmake -D${value}=ON ..
        # Generate make files with all compaction options off (falls back to no-compact)
        cmake ..
        # Build the project
        make -j96
        # Move the project
        mv ${name} ../${name}/exe_${key}_${name}
        # Return to parent directory
        cd ..
        rm -rf build-${key}
    done
done


