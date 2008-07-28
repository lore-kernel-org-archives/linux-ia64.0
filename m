From: Simon Horman <horms@verge.net.au>
Date: Mon, 28 Jul 2008 01:51:19 +0000
Subject: Re: [patch] crashdump: fix undefined reference to `elfcorehdr_addr'
Message-Id: <20080728015117.GA12055@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20080727234529.GM6175@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Muli Ben-Yehuda <muli@il.ibm.com>, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Terry Loftin <terry.loftin@hp.com>, Tony Luck <tony.luck@intel.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-ia64@vger.kernel.org

[ Updated Vivek's email address to his vgoyal@redhat.com in CC list 
  Added Terry Loftin, Tony Luck, Erik Biedermann and linux-ia64 to CC list ]

On Mon, Jul 28, 2008 at 09:45:31AM +1000, Simon Horman wrote:
> > > diff --git a/include/linux/crash_dump.h b/include/linux/crash_dump.h
> > > index 6cd39a9..025e4f5 100644
> > > --- a/include/linux/crash_dump.h
> > > +++ b/include/linux/crash_dump.h
> > > @@ -8,7 +8,13 @@
> > >  #include <linux/proc_fs.h>
> > >  
> > >  #define ELFCORE_ADDR_MAX	(-1ULL)
> > > +
> > > +#ifdef CONFIG_PROC_VMCORE
> > >  extern unsigned long long elfcorehdr_addr;
> > > +#else
> > > +static const unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
> > > +#endif
> > > +
> > >  extern ssize_t copy_oldmem_page(unsigned long, char *, size_t,
> > >  						unsigned long, int);
> > >  extern const struct file_operations proc_vmcore_operations;
> > 
> > spose that'll fix it.  But it seems odd that is_kdump_kernel() will
> > return false if CONFIG_PROC_VMCORE=n, CONFIG_CRASH_DUMP=y.  I mean,
> > it's still a crashdump kernel, is it not?
> 
> Perhaps is_kdump_kernel() ought to be renamed kernel_has_vmcore().
> 
> To my mind, is_kdump_kernel() should really look something like this:
> 
> #ifdef CONFIG_CRASH_DUMP
> static inline int is_kdump_kernel(void) { return 1; }
> #else
> static inline int is_kdump_kernel(void) { return 0; }
> #endif
> 
> But that can probably just be handled by any relevant code
> using CONFIG_CRASH_DUMP as necessary.

Hi,

I started looking into a simple fix to change the name of
the is_kdump_kernel() to kernel_has_vmcore(), which is what
the code in its current incarnatation does.

This also lead to cleaning the usage of elfcorehdr_addr,
which is in the folloing messy state after recent changes.

#ifdef CONFIG_PROC_VMCORE
* Declared non-static include/linux/crash_dump.h
* Initialised in fs/proc/vmcore.c
#else
* Declared and initialised as static in include/linux/crash_dump.h
* Only used by is_kdump_kernel() which is a static function
  also in include/linux/crash_dump.h
#endif


Howerver, in the course of doing this I came to thinking that actually
this code won't solve the problem at hand in the case where
CONFIG_CRASH_DUMP is defined but CONFIG_PROC_VMCORE is not.
Or in other words, what happens if the calgary initialisation code
runs in a kdump kernel that does not have CONFIG_PROC_VMCORE ?

A similar problem appears to exist in
arch/ia64/hp/common/sba_iommu.c:sba_init(), which currently doesn't
compile if CONFIG_CRASH_DUMP is set but CONFIG_PROC_VMCORE is not.  The
compilation issue could be solved by using kernel_has_vmcore() (as per
the patch below) instead of checking elfcorehdr_addr directly, but does
it actually lead to working code?

There has long been a strong aversion to providing the second
kernel with flags like im_in_kexec or im_in_kdump, as its felt
that this kind of problem is better handled by making sure that the
hardware is in a sensible state before leaving the first-kernel.
But this is arguably more reasonable in the kexec case than the
kdump case.


If there really is a need for kdump kernels to know that they are
booting a kdumping system, then I propose one of the following:

1) Always parse the elfcorehdr kernel command line option
   and set elfcorehdr_addr accordingly - currently this is only
   done if CONFIG_PROC_VMCORE is set.

   This is nice as it won't need any modifications to kexec-tools
   nor any command line bloat.

   A minor difficulty is working out where to initialise elfcorehdr_addr.
   Sometimes in include/linux/crash_dump.h and sometimes in
   fs/proc/vmcore.c seems horrible to me.

   Another problem is that would be alive and well in
   code that really only uses it to check if kdump was activated or not
   - a minor naming issue.

2) Add a new kernel command line option, perhaps in_kdump

   This is bloat to get around elfcorehdr_addr initialisation and
   naming awkwardness above.

3) Make select CONFIG_PROC_VMCORE when CONFIG_CRASH_DUMP is selected,
   or perhaps even just remove CONFIG_PROC_VMCORE and only use
   CONFIG_CRASH_DUMP instead. The effect would be the same either way.

   Pro: One less thing to be confused about

   Con: Bloat for people who want kdump without vmcore.
        I wonder what usage case that is.

-- 
Horms

Index: linux-2.6/arch/x86/kernel/pci-calgary_64.c
=================================--- linux-2.6.orig/arch/x86/kernel/pci-calgary_64.c	2008-07-28 10:10:31.000000000 +1000
+++ linux-2.6/arch/x86/kernel/pci-calgary_64.c	2008-07-28 10:14:24.000000000 +1000
@@ -801,7 +801,7 @@ static int __init calgary_setup_tar(stru
 	tbl = pci_iommu(dev->bus);
 	tbl->it_base = (unsigned long)bus_info[dev->bus->number].tce_space;
 
-	if (is_kdump_kernel())
+	if (kernel_has_vmcore())
 		calgary_init_bitmap_from_tce_table(tbl);
 	else
 		tce_free(tbl, 0, tbl->it_size);
@@ -1184,7 +1184,7 @@ static int __init calgary_init(void)
 		return ret;
 
 	/* Purely for kdump kernel case */
-	if (is_kdump_kernel())
+	if (kernel_has_vmcore())
 		get_tce_space_from_tar();
 
 	do {
@@ -1438,7 +1438,7 @@ void __init detect_calgary(void)
 		return;
 	}
 
-	specified_table_size = determine_tce_table_size((is_kdump_kernel() ?
+	specified_table_size = determine_tce_table_size((kernel_has_vmcore() ?
 					saved_max_pfn : max_pfn) * PAGE_SIZE);
 
 	for (bus = 0; bus < MAX_PHB_BUS_NUM; bus++) {
@@ -1461,7 +1461,7 @@ void __init detect_calgary(void)
 			 * If it is kdump kernel, find and use tce tables
 			 * from first kernel, else allocate tce tables here
 			 */
-			if (!is_kdump_kernel()) {
+			if (!kernel_has_vmcore()) {
 				tbl = alloc_tce_table();
 				if (!tbl)
 					goto cleanup;
Index: linux-2.6/fs/proc/vmcore.c
=================================--- linux-2.6.orig/fs/proc/vmcore.c	2008-07-28 09:51:30.000000000 +1000
+++ linux-2.6/fs/proc/vmcore.c	2008-07-28 09:51:53.000000000 +1000
@@ -32,8 +32,7 @@ static size_t elfcorebuf_sz;
 /* Total size of vmcore file. */
 static u64 vmcore_size;
 
-/* Stores the physical address of elf header of crash image. */
-unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+unsigned long long elfcorehdr_addr;
 
 struct proc_dir_entry *proc_vmcore = NULL;
 
Index: linux-2.6/include/linux/crash_dump.h
=================================--- linux-2.6.orig/include/linux/crash_dump.h	2008-07-28 09:46:29.000000000 +1000
+++ linux-2.6/include/linux/crash_dump.h	2008-07-28 10:43:03.000000000 +1000
@@ -11,8 +11,13 @@
 
 #ifdef CONFIG_PROC_VMCORE
 extern unsigned long long elfcorehdr_addr;
+
+static inline int kernel_has_vmcore(void)
+{
+	return (elfcorehdr_addr != ELFCORE_ADDR_MAX) ? 1 : 0;
+}
 #else
-static const unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+static inline int kernel_has_vmcore(void) { return 0; }
 #endif
 
 extern ssize_t copy_oldmem_page(unsigned long, char *, size_t,
@@ -28,12 +33,6 @@ extern struct proc_dir_entry *proc_vmcor
 
 #define vmcore_elf_check_arch(x) (elf_check_arch(x) || vmcore_elf_check_arch_cross(x))
 
-static inline int is_kdump_kernel(void)
-{
-	return (elfcorehdr_addr != ELFCORE_ADDR_MAX) ? 1 : 0;
-}
-#else /* !CONFIG_CRASH_DUMP */
-static inline int is_kdump_kernel(void) { return 0; }
 #endif /* CONFIG_CRASH_DUMP */
 
 extern unsigned long saved_max_pfn;

