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

#copyright;
#=====end of copyright notice=====

#set -x;

get_vm_id()
{
      Hypervisor=$1;
      VMName=$2;
      VMId=`ssh $Hypervisor "vim-cmd /vmsvc/getallvms" | grep $VMName | /utils/text/at_position.sh 1`;
      echo $VMId;
}

vm_state()
{
	Hypervisor=$1;
	VMName=$2;
	VMId=`get_vm_id $Hypervisor $VMName`;
	ssh $Hypervisor "vim-cmd /vmsvc/power.getstate $VMId" | grep "Powered" | /utils/text/at_position.sh 2;
}

wait_vm_state()
{
	HV=$1;
	VM=$2;
	State=$3;
		
	while true;
	do
		VMState=`vm_state $HV $VM`;
		if [ "$VMState" == "$State" ]; then
			echo "=== $VM on $HV to has got into state: $State";
			return;
		fi;
		echo "... Waiting $VM on $HV to get into state: $State";
		sleep 1s;
	done;
}

turn_vm_state()
{
	HV=$1;
	VM=$2;
	NewState=$3;

  	VMState=`vm_state $HV $VM`;
        if [ "$VMState" == "$NewState" ]; then
	        return;
        fi;
	
	case $NewState in 
		( "on" )
			VMId=`get_vm_id $HV $VM`;
			ssh $HV "vim-cmd /vmsvc/power.on $VMId";
		;;
		( "off" )
#			if ping -w 2 $VM; then
#			{
				timeout 60s ssh $VM '/utils/ibm/was.sh stop; su -lc "db2stop force" db2inst';
				timeout 10s ssh $VM "shutdown -Ph now";
#			} fi;
		;;
	esac;
	wait_vm_state $HV $VM $NewState;
}


hw_reset_vm()
{

set -x;

	HV=$1;
	VM=$2;

	VMId=`get_vm_id $HV $VM`;
	ssh $HV "vim-cmd /vmsvc/power.reset $VMId";
}


set_dns()
{
	HV=$1;
	DNSHost=$2;
	ssh $HV "esxcli network ip dns server add -s " & DNSHost;
	ssh $HV "esxcli network ip dns server list";
}

#set -x;

Action=$1;
Args=${@:2};

# !!! === LIST LIST VMs:
# vim-cmd vmsvc/getallvms

$Action $Args;                