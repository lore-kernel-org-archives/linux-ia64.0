From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Mon, 22 Aug 2005 22:02:47 +0000
Subject: RE: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <516F50407E01324991DD6D07B0531AD55F6E65@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for the review Arun. 

> You mean at compile time? Runtime would be interesting as...

The transparent paravirtualization approach I use could be easily
extended to support more than one hypervisor selected at
runtime.

> But the bigger question we haven't answered is:
> Is an instruction level approach sufficient to build a high 
> performance hypervisor?

Define "high performance hypervisor"... Would "within a
few percent of native" qualify?  Xen/ia64 admittedly hasn't
gone through a wide range of performance tests but
domain0* currently compiles linux at only 4% slower than
native and I expect this to get closer to 2% with some more
work (and without additional changes to the patch).  A domU*
guest will be slower due to I/O overhead but I/O is already
using higher level primitives (the same ones as x86).

Dan

* For those not familiar with Xen terminology:
  domain0: the "host" or "service" virtual machine
  domU: a "guest" virtual machine 

> -----Original Message-----
> From: Arun Sharma [mailto:arun.sharma@intel.com] 
> Sent: Monday, August 22, 2005 3:46 PM
> To: Magenheimer, Dan (HP Labs Fort Collins)
> Cc: linux-ia64@vger.kernel.org
> Subject: Re: Xen and the Art of Linux/ia64 Virtualization
> 
> Magenheimer, Dan (HP Labs Fort Collins) wrote:
> 
> Hi Dan,
> 
> > Revision 5.  Incorporates abstraction changes to ia64_getreg
> > and ia64_setreg as suggested by David Mosberger and Tony
> > Luck.  Also generalized a bit so that it will be easy to
> > support other virtualization software that may come along.
> 
> You mean at compile time? Runtime would be interesting as 
> well, but that 
> would mean moving the macros out of line.
> 
> > This patch is currently against 2.6.12 (thus for review only).
> > 
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@hp.com>
> > 
> 
> The patch looks pretty clean to me (except for the CONFIG_XEN 
> comment I 
> sent to xen-merge). But the bigger question we haven't answered is:
> 
> Is an instruction level approach sufficient to build a high 
> performance 
> hypervisor?
> 
> This question is being actively debated on the x86 side as 
> well.  If the 
> answer turns out to be "no" and if after doing some performance 
> analysis, we conclude that higher level primitives are 
> needed, then some 
> of these changes would not be needed (because those privilege 
> sensitive 
> instructions have been replaced by a higher level primitive).
> 
> 	-Arun
> 
