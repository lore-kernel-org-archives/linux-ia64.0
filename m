From: Nick Pollitt <npollitt@sgi.com>
Date: Tue, 15 Jan 2002 01:07:19 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805826@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What .config are you using?  I grabbed the defconfig-bigsur-mp
and compiled with your patch (had to disable DEVFS_DEBUG).  The
kernel doesn't get very far into the boot, less than a second,
and it fails.  Of course you said it would.  But I couldn't get
any useful info from the console so I ran the kernel in medusa.

In case you try this, it executes to about 15301000.  Then it
fails in acpi_hw_low_level_read.  I also tried with the kernel
patch I sent out Friday, which dies much sooner than this.  But
it's definitely not getting into schedule in my machine.

Did you config off other stuff (all the ACPI)? 

Nick

On Mon, Jan 14, 2002 at 07:23:31PM +0100, Erich Focht wrote:
> Hi,
> 
> I don't think that runqueues(cpu)->idle is set when you try to access it
> from head.S. It is much easier to reintroduce init_tasks and leave head.S
> as it is. Then no changes are needed in Ingo's patch for sched.h and
> sched.c. Ingo, could you please comment?
> 
> Please find attached an ia64 patch which should be applied over
> 2.4.17 + ia64 + sched-O1-2.4.17-H7.patch
> 
> 
> It doesn't boot yet, the system (2CPU BigSur) crashes in
>   schedule() <- cpu_idle() <- rest_init() <- start_kernel()
> Maybe somebody has an idea?
> 
> Thanks,
> 
> Erich
> 
> ---
> Erich Focht                                    <efocht@ess.nec.de>
> NEC European Supercomputer Systems, European HPC Technology Center
> 

-- 
Nick Pollitt                                   phone: 650.933.7406
Scalable Linux Project                           fax: 650.932.0317
Silicon Graphics, Inc.                       npollitt@engr.sgi.com

