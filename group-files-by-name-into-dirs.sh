#!/usr/bin/env bash

if [ ! $# -ge 3 ]; then
    echo
    echo "Usage: group-files-by-name-into-dirs.sh <directory> <char_start> <char_stop> <mode>"  
    echo
    echo "       directory:  The directory containing the files to group"
    echo "       char_start: Integer number of the character in file names to start using for grouping."
    echo "       char_stop:  Integer number of the character in file names to stop using for grouping. "
    echo "       mode:       cp for copying, mv for moving files into new group directories."
    echo "                   Optional, default mode is copying the files." 
    echo

elif [ ! -d $1 ]; then
    echo
    echo "First parameter must be a valid directory. $1 does not exist."
    echo
else
    INPUT_PATH=$1

    files=($( ls -p $INPUT_PATH | grep -v / ))

    if [ ${#files[@]} -eq 0 ]; then
	echo "Input directory does not seem to contain any files: $INPUT_PATH"
	echo "Exiting."
	exit 1
    else
	echo "Found ${#files[@]} files in input directory"
	# Make sure there is no old temporary data around
	rm -rf $INPUT_PATH/.temp_group_dir/
    fi

    char_start=$2
    char_stop=$3
    if [[ $char_start =~ ^-?[0-9]+$ ]]; then
	echo "Set start character to $char_start"
    else
	echo "No valid start character provided ($char_start)."
	echo "Setting start character to 0 ..."
	char_start=0
    fi

    if [[ $char_stop =~ ^-?[0-9]+$ ]]; then
	echo "Set stop character to $char_stop"
    else
	echo "No valid stop character provided ($char_stop)."
	echo "Setting stop character to -1 (i.e. condsider full filenames) ..."
	char_stop=-1
    fi

    if [ $# -eq 4 ]; then
	proc_mode=$4
	if [ "$proc_mode" == "mv" ] || [ "$proc_mode" == "move" ] || [ "$proc_mode" == "Move" ]; then
	    proc_mode="mv"
	else
	    proc_mode="cp"
	fi
    else
	proc_mode="cp"
    fi
		           
    
    # Find groups of equal filename parts
    new_dirname="none_none_none"
    declare -a dir_names

    echo "Scanning filenames for groups ..."
    
    for file in ${files[@]}; do
	if [ "$new_dirname" == "none_none_none" ]; then
	    new_dirname=${file:$char_start:$char_stop}
	    # echo "First element in list is $new_dirname"
	    dir_names+=($new_dirname)
	else
	    new_dirname=${file:$char_start:$char_stop}
	    if printf '%s\n' ${dir_names[@]} | grep -q -P "^$new_dirname$"; then
		# echo "$new_dirname is already in the list."
		:
	    else
		# echo "Appending $new_dirname to list."
		dir_names+=($new_dirname)
	    fi
	fi
    done
   
    for dir_name in ${dir_names[@]}; do	
	# Create directories for unique filename parts
	echo "Creating $dir_name"
	mkdir -p "$INPUT_PATH/.temp_group_dir/$dir_name"
	rm -rf "$INPUT_PATH/$dir_name"
	if [ "$proc_mode" == "mv" ]; then
	    mv $INPUT_PATH/*${dir_name}* $INPUT_PATH/.temp_group_dir/$dir_name
	else
	    cp $INPUT_PATH/*${dir_name}* $INPUT_PATH/.temp_group_dir/$dir_name
	fi
    done

    # Copy/Move files into new dirs (depending on mode if set)
    echo "Cleaning up ..."
    mv $INPUT_PATH/.temp_group_dir/* $INPUT_PATH
    rm -rf $INPUT_PATH/.temp_group_dir/

    echo "Processing finished"; echo      
fi
