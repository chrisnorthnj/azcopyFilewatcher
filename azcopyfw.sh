#!/bin/bash
#
#

#  This script is intended and shared as an example of how to incorporate AzCopy with a simple inotifywait file watch.
#
#  It is NOT intended to be used in any production environment and no guarantee or SLA is provided or implied by Microsoft or the individual(s) who authored or shared it.
#  Use of this script should be limited to proof-of-concept work only within a non-production environment.
#  Please consider this script to be an informational example only - use at your own risk.
#


## Set these variables to indicate the directory you want to watch for new/changed files, and your destintation storage account details.

WATCHPATH=/example/path/to/files
STORAGEACCT="mystorageaccountname"
CONTAINER="myblobs"
STORAGEKEY="LONGSTORAGEACCOUNTKEYSTRINGHERE"

## Here is the actual moving parts.  You shouldn't need to change anything here for it to work

inotifywait -m -e create -e moved_to -e modify ${WATCHPATH}  | while read path action file
do

    ## Announce what we found
    echo "Copying ${file} from ${path} based on action detected ${action}"

    ## Actually copy the file
    azcopy --source ${path}${file} --destination https://${STORAGEACCT}.blob.core.windows.net/${CONTAINER}/$file --dest-key ${STORAGEKEY}

    ## Some very basic error checking to avoid accidental deletion
    if [ $? -eq 0 ]; then
        rm ${path}${file} 2>/dev/null
    else
        echo "ERROR copying $file from $path - file not deleted"
    fi

done
