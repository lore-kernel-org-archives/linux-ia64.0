From: Zou Nan hai <nanhai.zou@intel.com>
Date: Thu, 08 Feb 2007 04:21:02 +0000
Subject: Re: Zero size /proc/vmcore on ia64
Message-Id: <1170908462.3230.11.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2007-02-08 at 13:34, Vivek Goyal wrote:
> On Thu, Feb 08, 2007 at 12:06:53PM +0900, Horms wrote:
> > On Thu, Feb 08, 2007 at 10:07:48AM +0800, Zou, Nanhai wrote:
> > > 
> > > Hi Vivek,
> > >     I have a question about why saved_max_pfn check in vmcore.c is
> needed.
> > > Here is a typical memory layout of IA64 machine.
> > > 
> > > ----- ==>max_pfn for first kernel
> > >      the first kernel
> > > ----- ==>max_pfn for crash dump kernel
> > > the crash dump kernel
> > > -----       
> > > the first kernel
> > > ----- 
> > > 
> > > When crash dump kernel tries to access memory of first kernel
> above
> > > saved_max_pfn of him, read_from_oldmem will refuse that read.
> > > 
> > > That result an empty vmcore file. change saved_max_pfn to unsigned
> > > long(-1) will fix this issue.
> > > 
> > > However since memory ranges in vmcore is pre defined from
> /proc/iomem
> > > of first kernel, why do we still need to add an extra check in
> > > vmcore.c
> > 
> > Hi Nan-hai,
> > 
> > sorry that I did not get back to you about the information you
> requested
> > about my system, I guess you have managed to reproduce the problem
> none
> > the less.
> > 
> > I can confirm that removing the max_pfn check in vmcore.c does
> > indeed give /proc/vmcore a non-zero (and presumably correct) size.
> > 
> > I wonder if the problem is that saved_max_pfn is being incorectly
> > calculated on ia64. That it is being set to the max_pfn of the
> > crash kernel (i.e. in the crashkernel=X@Y area), rather than
> > the max_pfn of the physical memory of the system, which seems
> > more sensible as the purpose of vmcore is to read memory
> > outside of the crashkernel=X@Y area.
> > 
> 
> Hi Horms/Nan-hai,
> 
> Horms, you are right. saved_max_pfn is needed to know that second
> kernel
> is not trying to read any memory which is not present or was not being
> used by the crashed kernel at all. That's why in i386/x86_64, during
> early boot saved_max_pfn, is calculated the memory map passed to the
> second
> kernel. This memory map is passed to second kernel by kexec through
> parameter
> segment. So effectively saved_max_pfn will be set to max_pfn of
> crashed kernel.
> 
> Now this memory map is overwritten with user defined one which is
> basically
> the memory second kernel can use to boot and max_pfn now will be
> maximum
> pfn crash kernel can use.
> 
> > You may be right that we can just remove the check all together,
> > though perhaps it is there for the case where the range information
> > in the vmcode are corrupted. Then again, should we care about this?
> 
> I think we should not remove this check because even to parse the info
> passed in ELF headers, you need to first read the ELF headers from
> crashed
> kernel's memory. So if some programming error has passed wrong
> location of
> ELF headers (elfcoreheader= invalid location) then we might try
> reading the
> elf header from a non-existing physical page frame.
> 
> So the right way should be to set saved_max_pfn with right value
> before it
> is memory map is over-written with user defined memory map.
> 
	This is reasonable.
	So please apply the following patch to make saved_max_pfn point to
max_pfn of entire system.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup linux-2.6.20/arch/ia64/kernel/efi.c linux-2.6.20-fix/arch/ia64/kernel/efi.c
--- linux-2.6.20/arch/ia64/kernel/efi.c	2007-02-04 13:44:54.000000000 -0500
+++ linux-2.6.20-fix/arch/ia64/kernel/efi.c	2007-02-08 01:56:18.000000000 -0500
@@ -21,6 +21,7 @@
  *	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/module.h>
+#include <linux/bootmem.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/types.h>
@@ -1010,6 +1011,11 @@ efi_memmap_init(unsigned long *s, unsign
 		} else
 			ae = efi_md_end(md);
 
+#ifdef CONFIG_CRASH_DUMP
+		/* saved_max_pfn should ignore max_addr= command line arg */ 
+		if (saved_max_pfn < (ae >> PAGE_SHIFT))
+			saved_max_pfn = (ae >> PAGE_SHIFT);
+#endif
 		/* keep within max_addr= and min_addr= command line arg */
 		as = max(as, min_addr);
 		ae = min(ae, max_addr);
diff -Nraup linux-2.6.20/arch/ia64/mm/contig.c linux-2.6.20-fix/arch/ia64/mm/contig.c
--- linux-2.6.20/arch/ia64/mm/contig.c	2007-02-04 13:44:54.000000000 -0500
+++ linux-2.6.20-fix/arch/ia64/mm/contig.c	2007-02-08 01:56:03.000000000 -0500
@@ -175,11 +175,6 @@ find_memory (void)
 
 	find_initrd();
 
-#ifdef CONFIG_CRASH_DUMP
-	/* If we are doing a crash dump, we still need to know the real mem
-	 * size before original memory map is * reset. */
-	saved_max_pfn = max_pfn;
-#endif
 }
 
 #ifdef CONFIG_SMP



> Thanks
> Vivek
> 
