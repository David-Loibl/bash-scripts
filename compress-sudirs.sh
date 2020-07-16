#!/usr/bin/env bash

if [ ! $# -eq 1 ]; then
    echo
    echo "Usage: compress-multiple-subdirs.sh <directory> "  
    echo 
    echo "       directory:  The directory containing the files to group"
    echo

elif [ ! -d $1 ]; then
    echo
    echo "First parameter must be a valid directory. $1 does not exist."
    echo
else
    INPUT_PATH=$1

    current_dir=$( pwd )

    cd $INPUT_PATH
    subdirs=($( ls -d */ ))
    
    if [ ${#subdirs[@]} -eq 0 ]; then
	echo "Input directory does not seem to contain any sub-directories to compress: $INPUT_PATH"
	echo "Exiting."
	exit 1
    else
	echo "Found ${#subdirs[@]} sub-directories in input directory"
	# Make sure there is no old temporary data around
    fi

    for subdir in ${subdirs[@]}; do
	echo; echo "Creating ${subdir::-1}.tar.gz ..."
	tar -czvf ${subdir::-1}.tar.gz $subdir
    done

    echo "Processing finished"; echo      
fi
