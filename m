From: Horms <horms@verge.net.au>
Date: Tue, 12 Dec 2006 08:49:03 +0000
Subject: [PATCH] [IA64] CONFIG_KEXEC and CONFIG_CRASH_DUMP
Message-Id: <20061212084901.GK18377@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 12, 2006 at 03:54:51PM +0900, Horms wrote:
> On Mon, Dec 11, 2006 at 03:58:18PM -0800, Luck, Tony wrote:
> > The kexec/crash_dump patches for ia64 have gone into Linus'
> > tree ... but there are some loose ends to tidy up.  One of them
> > is what is supposed to happen if I configure CONFIG_KEXEC=y with
> > CONFIG_CRASH_DUMP=n or CONFIG_KEXEC=n with CONFIG_CRASH_DUMP=y.
> > 
> > The current result is build errors unless both are 'n' or both
> > are 'y'.  Looking at Documentation/kdump/kdump.txt it looks like
> > the original intent was that CONFIG_KEXEC=y be used for the normal
> > kernel that you run all the time, and CONFIG_CRASH_DUMP=y be used
> > for the kernel that you transfer to when bad stuff has happened to
> > actually dump memory.
> > 
> > But on ia64 I don't think that we need such a distinction.  We don't
> > need to link the crashdump kernel at a special address, so it can
> > be the same binary as our normal kernel.
> > 
> > I did take a quick look at untangling KEXEC/CRASH_DUMP ... but
> > there seem to be a few places where the ia64 port assumes that
> > both are either set or not set.
> > 
> > Perhaps the path of least resistance would be to just fix
> > arch/ia64/Kconfig to only offer a single "kexec + crashdump"
> > option that sets both CONFIG options?  Or are there other
> > benefits/reasons to keep separate options?
> 
> I doubt that there is a benifit other than consistency with
> other architectures. I'll cook up a patch to merge them as
> you suggest, as appart from anything else, it should
> avoid missusing them in future.

Actually, on reflection I think that there is a good case for
keeping the options separate. I am thinking particularly of people
who want a very small crashdump kernel and thus don't want to compile
in kexec.

The patch below should fix things up so that all valid combinations of 
KEXEC, CRASH_DUMP and VMCORE compile cleanly - VMCORE depends on
CRASH_DUMP which is why I said valid combinations. In a nutshell 
it just untangles unrelated code and switches around a few defines.

Please note that it creats a new file, arch/ia64/kernel/crash_dump.c
This is in keeping with the i386 implementation. 

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/Makefile
=================================--- linux-2.6.orig/arch/ia64/kernel/Makefile	2006-12-12 17:40:52.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/Makefile	2006-12-12 17:40:54.000000000 +0900
@@ -29,6 +29,7 @@
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
 obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o crash.o
+obj-$(CONFIG_CRASH_DUMP)	+= crash_dump.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 obj-$(CONFIG_AUDIT)		+= audit.o
 obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2006-12-12 17:40:51.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2006-12-12 17:40:54.000000000 +0900
@@ -19,29 +19,11 @@
 
 #include <asm/kdebug.h>
 #include <asm/mca.h>
-#include <asm/uaccess.h>
 
 int kdump_status[NR_CPUS];
 atomic_t kdump_cpu_freezed;
 atomic_t kdump_in_progress;
 int kdump_on_init = 1;
-ssize_t
-copy_oldmem_page(unsigned long pfn, char *buf,
-		size_t csize, unsigned long offset, int userbuf)
-{
-	void  *vaddr;
-
-	if (!csize)
-		return 0;
-	vaddr = __va(pfn<<PAGE_SHIFT);
-	if (userbuf) {
-		if (copy_to_user(buf, (vaddr + offset), csize)) {
-			return -EFAULT;
-		}
-	} else
-		memcpy(buf, (vaddr + offset), csize);
-	return csize;
-}
 
 static inline Elf64_Word
 *append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
@@ -225,14 +207,10 @@
 static int
 machine_crash_setup(void)
 {
-	char *from = strstr(saved_command_line, "elfcorehdr=");
 	static struct notifier_block kdump_init_notifier_nb = {
 		.notifier_call = kdump_init_notifier,
 	};
 	int ret;
-	if (from)
-		elfcorehdr_addr = memparse(from+11, &from);
-	saved_max_pfn = (unsigned long)-1;
 	if((ret = register_die_notifier(&kdump_init_notifier_nb)) != 0)
 		return ret;
 #ifdef CONFIG_SYSCTL
Index: linux-2.6/arch/ia64/kernel/mca.c
=================================--- linux-2.6.orig/arch/ia64/kernel/mca.c	2006-12-12 17:40:52.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/mca.c	2006-12-12 17:40:54.000000000 +0900
@@ -1239,7 +1239,7 @@
 	} else {
 		/* Dump buffered message to console */
 		ia64_mlogbuf_finish(1);
-#ifdef CONFIG_CRASH_DUMP
+#ifdef CONFIG_KEXEC
 		atomic_set(&kdump_in_progress, 1);
 		monarch_cpu = -1;
 #endif
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2006-12-12 17:40:52.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2006-12-12 17:41:13.000000000 +0900
@@ -434,6 +434,21 @@
 }
 early_param("nomca", setup_nomca);
 
+#ifdef CONFIG_PROC_VMCORE
+/* elfcorehdr= specifies the location of elf core header
+ * stored by the crashed kernel.
+ */
+static int __init parse_elfcorehdr(char *arg)
+{
+	if (!arg)
+		return -EINVAL;
+
+        elfcorehdr_addr = memparse(arg, &arg);
+	return 0;
+}
+early_param("elfcorehdr", parse_elfcorehdr);
+#endif /* CONFIG_PROC_VMCORE */
+
 void __init
 setup_arch (char **cmdline_p)
 {
Index: linux-2.6/arch/ia64/kernel/smp.c
=================================--- linux-2.6.orig/arch/ia64/kernel/smp.c	2006-12-12 17:40:51.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/smp.c	2006-12-12 17:40:54.000000000 +0900
@@ -157,7 +157,7 @@
 			      case IPI_CPU_STOP:
 				stop_this_cpu();
 				break;
-#ifdef CONFIG_CRASH_DUMP
+#ifdef CONFIG_KEXEC
 			      case IPI_KDUMP_CPU_STOP:
 				unw_init_running(kdump_cpu_freeze, NULL);
 				break;
@@ -219,7 +219,7 @@
 	send_IPI_single(smp_processor_id(), op);
 }
 
-#ifdef CONFIG_CRASH_DUMP
+#ifdef CONFIG_KEXEC
 void
 kdump_smp_send_stop()
 {
Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2006-12-12 17:40:52.000000000 +0900
+++ linux-2.6/arch/ia64/mm/contig.c	2006-12-12 17:40:54.000000000 +0900
@@ -174,6 +174,12 @@
 	reserve_bootmem(bootmap_start, bootmap_size);
 
 	find_initrd();
+
+#ifdef CONFIG_CRASH_DUMP
+	/* If we are doing a crash dump, we still need to know the real mem
+	 * size before original memory map is * reset. */
+	saved_max_pfn = max_pfn;
+#endif
 }
 
 #ifdef CONFIG_SMP
Index: linux-2.6/arch/ia64/kernel/crash_dump.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/arch/ia64/kernel/crash_dump.c	2006-12-12 17:40:54.000000000 +0900
@@ -0,0 +1,48 @@
+/*
+ *	kernel/crash_dump.c - Memory preserving reboot related code.
+ *
+ *	Created by: Simon Horman <horms@verge.net.au>
+ *	Original code moved from kernel/crash.c
+ *	Original code comment copied from the i386 version of this file
+ */
+
+#include <linux/errno.h>
+#include <linux/types.h>
+
+#include <linux/uaccess.h>
+
+/**
+ * copy_oldmem_page - copy one page from "oldmem"
+ * @pfn: page frame number to be copied
+ * @buf: target memory address for the copy; this can be in kernel address
+ *	space or user address space (see @userbuf)
+ * @csize: number of bytes to copy
+ * @offset: offset in bytes into the page (based on pfn) to begin the copy
+ * @userbuf: if set, @buf is in user address space, use copy_to_user(),
+ *	otherwise @buf is in kernel address space, use memcpy().
+ *
+ * Copy a page from "oldmem". For this page, there is no pte mapped
+ * in the current kernel. We stitch up a pte, similar to kmap_atomic.
+ *
+ * Calling copy_to_user() in atomic context is not desirable. Hence first
+ * copying the data to a pre-allocated kernel page and then copying to user
+ * space in non-atomic context.
+ */
+ssize_t
+copy_oldmem_page(unsigned long pfn, char *buf,
+		size_t csize, unsigned long offset, int userbuf)
+{
+	void  *vaddr;
+
+	if (!csize)
+		return 0;
+	vaddr = __va(pfn<<PAGE_SHIFT);
+	if (userbuf) {
+		if (copy_to_user(buf, (vaddr + offset), csize)) {
+			return -EFAULT;
+		}
+	} else
+		memcpy(buf, (vaddr + offset), csize);
+	return csize;
+}
+
