From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Mon, 10 Sep 2001 22:48:05 +0000
Subject: RE: [Linux-ia64] IA64 Linux Kernel Page Sizes
Message-Id: <marc-linux-ia64-105590698805162@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805131@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805131@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Erich,
I will put the kernel binary on ftp.intel.com (I'm currently having problems
ftping to that site) for you to download.  If you want I can put the tar of
modified files (no patch) on that site also.  And will let you know.
Meanwhile if you and Donny are in same place (both of you have ....nec... in
your addresses) then you can get the kernel binary and other info (for apps
to use this feature) from him.

I'll let you know once I have downloaded the files to ftp site.

rohit

-----Original Message-----
From: Erich Focht [mailto:focht@ess.nec.de]
Sent: Monday, September 10, 2001 1:32 PM
To: Seth, Rohit
Cc: Donny Cooper; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] IA64 Linux Kernel Page Sizes


Dear Rohit,

I'd like to try the super large pages which you mentioned in your mail. I
tried the 64k pages with IA64 Linux but the performance advantage was less
than expected (at least with the applications I used)...

Thanks a lot in advance!

Best regards,
Erich


---
Erich Focht                                    <efocht@ess.nec.de>
NEC European Supercomputer Systems, European HPC Technology Center


On Fri, 7 Sep 2001, Seth, Rohit wrote:

> I have an early prototype of super large page(256MB) implementation.  This
> is only a proof of concept for large apps (and configurations) to use
super
> large pages.  The use is for apps that need large data regions
(Instructions
> and regular data still use regular page size). Current implementation is
> through shared memory calls (shmat) with either SHM_LPAGE (a new flag) or
> size of requested segment >=LPAGE_SIZE(256MB).  In either case the size
has
> to be multiple of LPAGE_SIZE to get a large shared memory segment.
Further
> the whole physical memory is divided in two parts, one that is seen by
> kernel and the other that is only used to fill in large page requests.
And
> there is no moving of memory between two parts (in case of shortages).
This
> implementation is based on 2.4.5 kernel.  Currently IA-32 apps don't work
in
> this environment, but that can be fixed.
> 
> Let me know if this fits in your requirements and you want to give this a
> try.  I can send you a cut of (modified)tar files out of my source tree
> early next week.
> 
> rohit
> 
> -----Original Message-----
> From: Donny Cooper [mailto:dcooper@atcc.necsys.com]
> Sent: Thursday, September 06, 2001 9:23 AM
> To: linux-ia64@linuxia64.org
> Cc: Cooper (E-mail)
> Subject: [Linux-ia64] IA64 Linux Kernel Page Sizes
> 
> 
> (1) Below is a previous mail, from David M., responding to page size
> questions for IA64 kernels.
> 
> > As for the future: I'd like to start playing with superpage support
> > fairly soon (once I get some spare time on my hands... ;-).  With
> > superpages, physically contiguous regions of memory could be mapped
> > with a single TLB entry, giving you most of the benefit of (very)
> > large page sizes.	--david
> 
> Are there any updates on these plans?
> 
> 
> (2) Below are current available kernel options (from config).
> 
> 4KB	For best IA-32 compatibility
> 8KB   For best IA-64 performance
> 16KB 	For best IA-64 performance
> 64KB	Not for Itanium.
> 
> What is "IA64 best performance" based on?
> 
> We have a large memory system (32GB), and are not concerned with wasting
> memory during certain benchmarks.  Are 64KB
> pages truly not functional on Itanium, or just not recommended because of
> memory waste.  To my knowledge, HP-UX seems to
> benefit from 64KB pages on ITANIUM.
> 
> Any input or recommendation on these items is appreciated.
> 
> 
> Thanks.
> -----------------------------------
> Donny Cooper
> NEC Systems, Inc.
> Advanced Technical Computing Center
> dcooper@atcc.necsys.com
> www.necservers.com
> -----------------------------------

