#=====begin of copyright notice=====
copyright()
{
	echo -e "
	
	THE AULIX_UTILS FOR DEBIAN AND CENTOS \n
	The AUTHOR of this file is Alexander Borisovich Prokopyev, Kurgan, Russia \n
	More info can be found at the AUTHOR's website: http://www.aulix.com/resume \n
	Contact: alexander.prokopyev at aulix dot com \n
	 
	Copyright (c) Alexander Prokopyev, 2006-2014 \n
 
	All materials contained in this file are protected by copyright law. \n
	Nobody except the AUTHOR may alter or remove this copyright notice from copies of the content. \n
	 
	The AUTHOR allows to use this content under AGPL v3 license:
	http://opensource.org/licenses/agpl-v3.html
	
	";
}

copyright;
#=====end of copyright notice=====

OperationType=$1;
Source="$2";
Destination="$3";
Options=${@:4:20} # For example --delete --fake-super --compress --progress --omit-dir-times, etc 

#if test -z $SSH_SERVER_PORT; then
#	SSH_SERVER_PORT=22;
#fi

Result=0;

RSync()
{
	ionice -c 3 rsync --archive --one-file-system --hard-links --acls --xattrs --numeric-ids --progress  ${@:3:20} "$1" "$2";
#	-e 'ssh -c arcfour,aes256-cbc,aes256-ctr'
	Result=$?;
}

RSyncCompare()
{
    RSync --dry-run --delete --itemize-changes --verbose ${@:3:20} "$1" "$2";
    Result=$?;
     
}

echo "=== Backup of [$Source] =>>> [$Destination] started at `date` ===" 

case $OperationType in
	( system )
		RSync "$Source" "$Destination" --checksum --exclude-from=/utils/sys_dirs.txt $Options;
	    #--no-t
	;;
	( make_sys_dirs )
                cat /utils/sys_dirs.txt | /utils/text/for_each_line.sh "mkdir -p" .;		
	;;
	( data )
		RSync "$Source" "$Destination" --inplace --partial $Options;
	;;
	( data_ntfs )
		RSync "$Source" "$Destination" --inplace --partial --no-p --no-o --no-g --no-A $Options;
	;;
	( compare_strict )
		RSyncCompare "$Source" "$Destination" --checksum --no-t $Options;
	;;
	( compare )
		RSyncCompare "$Source" "$Destination" $Options;
	;;
	(*)
		echo "Option $1 is unknown. Please use on of the following: system, data, compare or compare_strict.";
		exit 1;
	;;
esac

echo -e "=== Backup of [$Source] to [$Destination] completed at `date` ===";

exit $Result;

# echo; cat /utils/fs/rsync.txt; echo;