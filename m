From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 19 Aug 2005 11:33:53 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <20050819113352.GA5715@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

So I spent some time investigating the booloader
problem with ski and gcc-4.0. I think I found the source
of the problem. The fix from Ian is not solving the problem
it is simply masking it.

The reason the SSC_WAIT_COMPLETION fails is because
the file descriptor being passed is wrong (0 instead of 3).

The reason why it is wrong is because it gets somehow overwritten
by the SSC_READ call. The bootloader works is you reload stat.fd
after the SSC_READ. 

The question becomes why is the stat structure overwritten?

I ran my tests using on I386 gcc-4.0 comiled ski. For
some reason gcc-4.0 dies compiling ski on IA-64.

On i386 ski, I noticed that due to alignment constraints
the disk_req structure as used by the bootloader has
a size of 16 bytes whereas on i386 ski the same structure
as a size of 12. Extra padding at the end o the struct
is added on Ia-64. This does not affect that particular
SSC_READ call we have in the bootloader because we only
pass 1 disk_req struct. Passing more than one would
systematically fail because the simulator is walking
the disk_req structure using += sizeof(disk_req). I think
this is a lurking problem that should somehow be fixed.

The real problem for the stat structure is that it gets
overwritten by the mem[] array and not disk_req. I added
some debug printf to the simulator and looked at the symbol
table for the bootloader. The mem[] array is static.
The disk_stat is allocated on the stack, I think. Now
with gcc-4.0 the mem[] array overlaps the disk_stat!

$ nm bootloader.gcc4 | fgrep mem
0000000000105410 b mem

The mem array is 4096, so it ends at 0x106410.
The ski trace shows that the SSC_WAIT_COMPLETION
disk_stat address is 0x106400. They overlap by 16 bytes!

I don't know what this is, looks like gcc-4.0 has a 
problem with the code in bootloader.c.

I used Debian/ia64 testing gcc-4.0: version 4.0.1 (Debian 4.0.1-2)
I used binutils Debian/ia64 testing 2.16.1

Hope this can help you track this down some more.

On Fri, Aug 19, 2005 at 09:58:16AM +1000, Peter Chubb wrote:
> >>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:
> 
> Stephane> On Fri, Aug 19, 2005 at 09:14:56AM +1000, Peter Chubb wrote:
> >> >>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:
> >> 
> Stephane> The simulator is not using the regular memcpy() routine it
> Stephane> has its own custom routine (which is not named memcpy).
> >>  This is a stupid suggestion, but...
> >> 
> >> Can you try recompiling the simulator with gcc 4.0, and see if the
> >> problem is still there?  If a gcc 4.0-compiled simulator that fixes
> >> the problem, and still allows booting of kernels compiled with icc,
> >> gcc-2.96, etc., etc., can be released, then we're done.
> >> 
> Stephane> Does this problem happen with the x86 and/or ia64 ski
> Stephane> version when bootloader is compiled with gcc-4.0?
> 
> IA64 and i386.
> 
> Stephane> I can certainly try to compile ski with gcc-4.0. Could
> Stephane> anyone of you send me his .config file to make sure we have
> Stephane> comparable kernels.
> 
> It's the arch/ia64/confis/sim_defconfig file in any recent kernel.
> 
> -- 
> Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
> The technical we do immediately,  the political takes *forever*

-- 

-Stephane
