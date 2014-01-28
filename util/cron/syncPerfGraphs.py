#!/usr/bin/env python

# This script is intended to sync the performance graphs for the current host
# onto sourceforge. It is separated from the nightly script for a couple of
# reasons: The nightly script is getting pretty monolithic already, we might
# not always want to sync data from all performance runs, and this serves as a
# place to capture notes about how we authenticate and some SF stuff. 

# rsync over ssh is used to transfer the files to SourceForge. The user running
# this script needs to have configured access to web.sourceforge.net.

# TODO This should also have an auxiliary function in it for syncing a new 
# .htaccess and .passwd file that are used as part of the HTML authentication


import os 
import subprocess 
import glob 
import shlex
import time

def main():
    sync = syncToSourceForge()
    if sync != 0: 
        exit(sync)

# Send the performance graphs for the current host to sourceforge 
# Log report to <nightly log dir>/syncToSourceForge.errors 
# Returns the status of the rsync command (0 on success) 
# or 124 if there was some non-rsync error with more details in the log file 
# or 125 if the log file couldn't be opened for any reason
# Use those values since they don't conflict with rsync or built in exit codes 
def syncToSourceForge():

    # try to open the log file 
    try:
        logDir = os.getenv('CHPL_NIGHTLY_LOGDIR') 
        logFileName = logDir + '/syncToSourceForge.errors'
        logFile = open(logFileName, 'w')
        logFile.write('Log for: ' + time.strftime("%m/%d/%Y") + '\n\n')
    except IOError:
        return 125
    
    # get the test perf dir and setup the rsync SRC
    testPerfDir = os.getenv('CHPL_TEST_PERF_DIR')
    if testPerfDir == None:
        logFile.write('CHPL_TEST_PERF_DIR was not set\n')
        logFile.close()
        return 124
    localPerfSrc = testPerfDir + '/html/'
    
    # Assumes correct username and authentication for web.sourceforge.net is
    # configured for the current system.
    sfPerfDest = 'web.sourceforge.net:/home/project-web/chapel/htdocs/perf/$host/'

    # The rsync command that we will execute -- authenticates over ssh 
    # --del to remove any old data (graphs merged, changed names, removed etc)
    rsyncCommand = 'rsync -avz --del -e ssh ' + localPerfSrc + ' ' + sfPerfDest
    logFile.write('Sync to sourceforge command was: ' + rsyncCommand + '\n\n')
    logFile.write('Rsync output is: \n')
    logFile.flush()

    # Actually send graphs to sourceforge and pipe output to the logfile 
    rsync = subprocess.call(shlex.split(rsyncCommand), stdout=logFile)
    
    if rsync == 0: 
        logFile.write('\n\nSuccessfully sent performance graphs to sourceforge')
    else: 
        logFile.write('\n\nFailure sending performance graphs to sourceforge')
    
    logFile.close()

    return rsync 


if __name__ == "__main__":
    main()
