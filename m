From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 18 Oct 2002 16:24:55 +0000
Subject: RE: [Linux-ia64] Kernel Shared Memory Max (shmmax)
Message-Id: <marc-linux-ia64-105590709805196@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The restriction is coming out of default parameters set in Linux (file
include/linux/shm.h).
These values could be changed through /proc/sys/kernel/shm* interface.  And
if a site permanentlly wants to have higher values for this parameters then
that can be achieved by something like rc.local

Have not seen any distribution increasing the default values for IA-64 yet.

rohit


> -----Original Message-----
> From: miyoshi@hpc.bs1.fc.nec.co.jp 
> [mailto:miyoshi@hpc.bs1.fc.nec.co.jp] 
> Sent: Thursday, October 17, 2002 6:07 PM
> To: rohit.seth@intel.com; dcooper@atcc.necsys.com
> Cc: ia64-list@redhat.com; linux-ia64@linuxia64.org; 
> jfredin@atcc.necsys.com
> Subject: Re: [Linux-ia64] Kernel Shared Memory Max (shmmax)
> 
> 
> 
> Hi,
> 
> I suppose '8G' described below means default shmall, that is 
> 524288 * 16K. And I think there is no restrictions around 8G on IA-64.
> 
> Regards,
> 
> > > And based on that the total amount of shared memory 
> segment that can 
> > > be created in IA-64 platform (with 16K page size) is 8G.
> > 
> > Does this still hold true in newer kernel releases (since 
> 03/2002)?  
> > Is 8G the
> > max for IA64 kernel?
> > 
> > Thanks,
> > Donny
> > 
> > On Thu March 14 2002 5:13 pm, Seth, Rohit wrote:
> > > shmmax is the size of largest shared memory (in bytes) 
> segment that 
> > > the kernel allows.  System wide value of total shared 
> memory value 
> > > is given by shmall parameter.  Currently the default value for 
> > > shmmax is  (extrememly
> > > low) 32MB.  And based on that the total amount of shared 
> memory segment
> > > that can be created in IA-64 platform (with 16K page 
> size) is 8G. There is
> > > no direct relationship between shmmax value and the 
> amount of physical
> > > memory available in the system.  Though you will never be 
> able to create a
> > > shared memory segment bigger then the total memory (Free 
> RAM+Free SWAP)
> > > available on the machine (unless you change the 
> sysctl_overcommit_memory).
> > > Besides that, this low default value of 32MB just adds 
> overhead for big
> > > memory systems.  It will be nice to change this default 
> value to 2G at
> > > least for IA-64 machines.
> > >
> > > You can also change this value of shm* (shmmax etc.) by writing 
> > > proper values in /proc/sys/kernel/shm*
> > >
> > > rohit
> > >
> > > -----Original Message-----
> > > From: Donny Cooper [mailto:dcooper@atcc.necsys.com]
> > > Sent: Thursday, March 14, 2002 2:40 PM
> > > To: ia64-list@redhat.com; linux-ia64@linuxia64.org
> > > Subject: [Linux-ia64] Kernel Shared Memory Max (shmmax)
> > >
> > >
> > >
> > > Does the maximum possible shared memory (shmmax) increase 
> with the 
> > > Enterprise kernel?
> > >
> > > Below is from doc/sysctl/kernel.txt document.
> > > Is this document valid for IA-64 kernel?
> > >
> > > It seems you can set this value to pretty much anything 
> (even larger 
> > > than the available memory), so I'm assuming the value gets 
> > > intelligently truncated to the max supported.  How can I 
> check how 
> > > much shared mem is available, `free` or `top` just shows what's 
> > > used, right?
> > >
> > > ...doc/sysctl/kernel.txt 
> > > ===============================
> > >
> > > shmmax:
> > >
> > > This value can be used to query and set the run time limit on the 
> > > maximum shared memory segment size that can be created. Shared 
> > > memory segments up to 1Gb are now supported in the kernel.  This 
> > > value defaults to SHMMAX.
> > >
> > > ===============================
> > >
> > >
> > > Thanks,
> > > -----------------------------------
> > > Donny Cooper
> > > NEC Systems, Inc.
> > > Advanced Technical Computing Center
> > > dcooper@atcc.necsys.com
> > > -----------------------------------
> > >
> > >
> > > _______________________________________________
> > > Linux-IA64 mailing list
> > > Linux-IA64@linuxia64.org 
> > > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > >
> > >
> > >
> > > _______________________________________________
> > > ia64-list mailing list
> > > ia64-list@redhat.com
> > 
> > --
> > ================> > 	     Donny Cooper
> >       NEC Solutions (America), Inc.
> > Advanced Technical Computing Center
> > 	 ph: +1-281-465-1506
> >      Donny.Cooper@NECsam.com
> > ================> > 
> > 
> > 
> > _______________________________________________
> > ia64-list mailing list
> > ia64-list@redhat.com 
> > https://listman.redhat.com/mailman/listinfo/ia64-list
> > 
> 

