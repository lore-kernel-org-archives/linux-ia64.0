From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 14 Mar 2002 23:13:35 +0000
Subject: RE: [Linux-ia64] Kernel Shared Memory Max (shmmax)
Message-Id: <marc-linux-ia64-105590701905287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

shmmax is the size of largest shared memory (in bytes) segment that the
kernel allows.  System wide value of total shared memory value is given by
shmall parameter.  Currently the default value for shmmax is  (extrememly
low) 32MB.  And based on that the total amount of shared memory segment that
can be created in IA-64 platform (with 16K page size) is 8G. There is no
direct relationship between shmmax value and the amount of physical memory
available in the system.  Though you will never be able to create a shared
memory segment bigger then the total memory (Free RAM+Free SWAP) available
on the machine (unless you change the sysctl_overcommit_memory).  
Besides that, this low default value of 32MB just adds overhead for big
memory systems.  It will be nice to change this default value to 2G at least
for IA-64 machines. 

You can also change this value of shm* (shmmax etc.) by writing proper
values in /proc/sys/kernel/shm*

rohit

-----Original Message-----
From: Donny Cooper [mailto:dcooper@atcc.necsys.com]
Sent: Thursday, March 14, 2002 2:40 PM
To: ia64-list@redhat.com; linux-ia64@linuxia64.org
Subject: [Linux-ia64] Kernel Shared Memory Max (shmmax)



Does the maximum possible shared memory (shmmax) increase with the
Enterprise kernel?

Below is from doc/sysctl/kernel.txt document.
Is this document valid for IA-64 kernel?

It seems you can set this value to pretty much anything (even larger than
the available memory), so I'm assuming the
value gets intelligently truncated to the max supported.  How can I check
how much shared mem is available, `free` or
`top` just shows what's used, right?

...doc/sysctl/kernel.txt
===============================

shmmax:

This value can be used to query and set the run time limit
on the maximum shared memory segment size that can be created.
Shared memory segments up to 1Gb are now supported in the
kernel.  This value defaults to SHMMAX.

===============================


Thanks,
-----------------------------------
Donny Cooper
NEC Systems, Inc.
Advanced Technical Computing Center
dcooper@atcc.necsys.com
-----------------------------------


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

