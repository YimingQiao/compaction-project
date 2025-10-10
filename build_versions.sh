#!/bin/bash

# Create compaction directory, -p option makes it ignore if the directory already exists
mkdir -p compaction
mkdir -p filter_and_join

# Compaction options as parallel arrays (for compatibility with older bash versions)
compaction_keys=("full" "binary" "dynamic")
compaction_values=("USE_FULL_COMPACT" "USE_BINARY_COMPACT" "USE_DYNAMIC_COMPACT")

# Define project names
executables=("filter_and_join" "compaction")

# Loop through all compaction options and compile projects
for name in "${executables[@]}"; do
    for i in "${!compaction_keys[@]}"; do
        key="${compaction_keys[$i]}"
        value="${compaction_values[$i]}"
        
        # Create a unique build directory for each option
        mkdir -p build-${key}-${name}
        cd build-${key}-${name}
        # Generate make files with the option enabled
        cmake -D${value}=ON ..
        # Build the project
        make -j96
        # Move the project
        mv ${name} ../${name}/exe_${key}_${name}
        # Return to parent directory
        cd ..
        rm -rf build-${key}-${name}
    done

    # Build the no_compact version
    mkdir -p build-no-${name}
    cd build-no-${name}
    # Generate make files with all compaction options off (falls back to no-compact)
    cmake ..
    # Build the project
    make -j96
    # Move the project
    mv ${name} ../${name}/exe_no_${name}
    # Return to parent directory
    cd ..
    rm -rf build-no-${name}
done
