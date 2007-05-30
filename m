From: David Chinner <dgc@sgi.com>
Date: Wed, 30 May 2007 04:44:48 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <20070530044448.GK86004887@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070522234314.54081817.akpm@linux-foundation.org> <617E1C2C70743745A92448908E030B2A01882BFD@scsmsx411.amr.corp.intel.com> <20070530033041.GH86004887@sgi.com>
In-Reply-To: <20070530033041.GH86004887@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Chinner <dgc@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, May 30, 2007 at 01:30:41PM +1000, David Chinner wrote:
> On Wed, May 23, 2007 at 10:44:16AM -0700, Luck, Tony wrote:
> > > > Saw this when running strace -f on a script on 2.6.21 on ia64:
> > > > 
> > > > BUG: sleeping function called from invalid context at kernel/fork.c:385
> > > > in_atomic():1, irqs_disabled():0
> >     ... snip ...
> > > > I could reproduce it via 'strace -f sleep 1'
> > > > 
> > >
> > > I'd say this is specific to ia64.   Someone would have spotted it on
> > > x86 by now.
> > 
> > I tried the "strace -f sleep 1" on 2.6.22-rc2, and I didn't see this "BUG"
> > there.  Can you try your other test cases on the latest kernel.  If it has
> > already been fixed we can see about identifying the patch for possible backport
> > to 2.6.21.stable
> 
> Sorry for taking so long to get back to this - I still see this in
> 2.6.22-rc2.

Hmmm - I wonder if my tree is screwed up in some weird way. I'm seeing link
warnings as well:

  AS      .tmp_kallsyms2.o
  LD      vmlinux
  SYSMAP  System.map
  SYSMAP  .tmp_System.map
  MODPOST vmlinux
WARNING: init/built-in.o - Section mismatch: reference to .init.data: from .sdata after 'root_mountflags' (at offset 0x38)
WARNING: init/built-in.o - Section mismatch: reference to .init.data:ino from .sdata after 'root_mountflags' (at offset 0x40)
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.data:smp_boot_data from .sdata before 'acpi_irq_model' (at offset -0x0)
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.data:rsvd_region from .sdata between 'ia64_sal' (at offset 0x118) and 'ia64_i_cache_stride_shift'
WARNING: arch/ia64/kernel/built-in.o - Section mismatch: reference to .init.data:smp_boot_data from .sdata between 'cpu.25267' (at offset0x2e8) and 'sal_state_for_booting_cpu'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x50) and 'first_time.25897'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x68) and 'first_time.25897'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x70) and 'first_time.25897'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x88) and 'first_time.25897'
WARNING: arch/ia64/mm/built-in.o - Section mismatch: reference to .init.data: from .sdata between 'hpage_shift' (at offset 0x90) and 'first_time.25897'
.....

There's more errors, but they are all section mismatch warnings.
I tried a make mrproper to see if that would fix but it didn't....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group
