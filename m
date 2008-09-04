From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 04 Sep 2008 23:52:03 +0000
Subject: RE: probe_kernel_address() causes MCA on bogus address
Message-Id: <1220572323.9767.5.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220483007.3254.51.camel@localhost.localdomain>
In-Reply-To: <1220483007.3254.51.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2008-09-04 at 16:22 -0700, Luck, Tony wrote:
> > This is a noticed side effect of trying to redo the function pointer
> > handling.  This code:
> >
> >        void *p1 = 0xdeadbeefdead0000, *p2 = 0xfeeddeadfeedbeef;
> >
> >        probe_kernel_address(p1, p2);
> >
> > causes an immediate MCA and reboot on my HP zx2000 wherever I execute it
> > in the kernel.  It's supposed to return -EFAULT.
> 
> It isn't really safe to call probe_kernel_address() with
> any old garbage address on any architeture (e.g. if you pass
> it a memory mapped I/O address that has side effects
> when read ... you won't die, but you will mess up some
> future piece of I/O).
> 
> That said ... ia64 does a particularly bad job with this.
> The reason is that the ia64 alt-dtlb miss handler assumes that
> all of region 6 (0xC...... & 0xD.....) and region 7 (0xE.....
> and 0xF.....) addresses map 1:1 with physical memory. Stray
> pointers in here result in TLB mappings being inserted for
> invalid physical addresses, which result in the MCA that you
> see.
> 
> Fixing this would be hard ... validating the physical address
> in the alt-dtlb miss handler on the exceptionally sparse address
> space on some ia64 platforms would add significant costs.
> 
> Perhaps ia64 could have its own real-function version of
> probe_kernel_address() that does a search of the EFI memory
> map ... this isn't used in any performance critical paths.

Oh, so I just picked a bad address to try it with?

OK .. all I was really trying to see was if ia64 would alter the target
of the probe_kernel_address() when the source faulted, but when I saw
the MCA I thought I should report it.

Thanks,

James


