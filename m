From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 03 Dec 2004 16:43:00 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <200412030843.00958.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_UeJsBnmRpuUhdRo"
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

--Boundary-00=_UeJsBnmRpuUhdRo
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday, December 3, 2004 8:31 am, Jesse Barnes wrote:
> [This is a repost of an earlier patch now that I've had time to finish it
> and test it more thoroughly.]
>
> This patch adds support for sending a SIGBUS to a userspace application
> using /proc/bus/pci to drive a device if an I/O error occurs.  We're using
> this in house for the X server's BIOS emulator and it seems to be working
> well.
>
> The idea is to track mmaped /proc/bus/pci regions so that the machine check
> handler is able to properly determine which process is responsible for any
> faults that occur (ia64 is interesting in that the error may not occur in
> the process context that actually generated the bad reference).  If a match
> is found, a SIGBUS is sent to the process, along with the address that
> caused the fault.  The machine check record is then cleared and recovery
> takes place (the assumption is that the signal to userspace is a sufficient
> record of the error).
>
> The patch also special cases memory mapping of legacy space, which is the
> first 64k of I/O space and the first megabyte of memory space.  Sub
> platforms can optionally remap their bridge to the target bus and setup
> legacy handling in the callout.
>
> Comments?  Given that this is working well for us, I'd like to get it
> upstream sometime soon.  I also expect that it could be used to deal with
> more types of I/O errors, perhaps allowing the kernel to call a driver
> shutdown routine if an I/O error occurs in a kernel driver.

Doh!  This is the updated one I meant to send.

Jesse

--Boundary-00=_UeJsBnmRpuUhdRo
Content-Type: text/plain;
  charset="iso-8859-1";
  name="io-error-sigbus-11.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="io-error-sigbus-11.patch"

===== arch/ia64/kernel/mca.c 1.71 vs edited =====
--- 1.71/arch/ia64/kernel/mca.c	2004-11-11 10:04:30 -08:00
+++ edited/arch/ia64/kernel/mca.c	2004-12-02 14:30:33 -08:00
@@ -814,8 +814,10 @@
 	ia64_os_to_sal_handoff_state.imots_sal_check_ra =
 		ia64_sal_to_os_handoff_state.imsto_sal_check_ra;
 
-	if (recover)
+	if (recover) {
 		ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_CORRECTED;
+		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
+	}
 	else
 		ia64_os_to_sal_handoff_state.imots_os_status = IA64_MCA_COLD_BOOT;
 
@@ -871,21 +873,69 @@
 void
 ia64_mca_ucmc_handler(void)
 {
+	struct io_range *range, *tmp;
+	unsigned long io_addr = 0;
 	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
 		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover; 
+	int recover = 0;
+	ia64_err_rec_t *curr_record;
 
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
-	/* TLB error is only exist in this SAL error record */
-	recover = (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
-	/* other error recovery */
-	   || (ia64_mca_ucmc_extension 
-		&& ia64_mca_ucmc_extension(
-			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
-			&ia64_sal_to_os_handoff_state,
-			&ia64_os_to_sal_handoff_state)); 
+ 	/* TLB errors are fixed up before we get here, so recover */
+ 	if (psp->tc) {
+ 		recover = 1;
+ 		goto return_to_sal;
+ 	}
+
+ 	/*
+ 	 * If it's not a bus check with a valid target identifier,
+ 	 * we don't have a chance.
+ 	 */
+ 	if (!psp->bc) {
+ 		recover = 0;
+ 		goto return_to_sal;
+ 	}
+
+ 	/*
+ 	 * If we can't get this lock, we can't safely look at the list,
+ 	 * so give up.
+ 	 */
+ 	if (!spin_trylock(&io_range_list_lock)) {
+ 		recover = 0;
+ 		goto return_to_sal;
+ 	}
+
+ 	curr_record = IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA);
+	io_addr = curr_record->proc_err.info->target_identifier;
+
+ 	/*
+ 	 * See if an I/O error occured in a previously registered range
+ 	 */
+ 	list_for_each_entry_safe(range, tmp, &pci_io_ranges, range_list) {
+ 		if (range->start <= io_addr && io_addr <= range->end) {
+ 			struct siginfo siginfo;
+ 			struct task_struct *owner = NULL;
+ 			recover = 1;
+ 			siginfo.si_signo = SIGBUS;
+ 			siginfo.si_code = BUS_ADRERR;
+ 			siginfo.si_addr  = (void *) io_addr;
+ 			owner = find_task_by_pid(range->owner);
+ 			if (owner)
+ 				force_sig_info(SIGBUS, &siginfo, owner);
+ 			else {
+ 				/*
+ 				 * need to free memory too, is that safe
+ 				 * here?
+ 				 */
+ 				list_del(&range->range_list);
+ 			}
+ 		}
+ 	}
+ 	spin_unlock(&io_range_list_lock);
+
+ return_to_sal:
 
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
===== arch/ia64/pci/pci.c 1.59 vs edited =====
--- 1.59/arch/ia64/pci/pci.c	2004-11-05 11:55:25 -08:00
+++ edited/arch/ia64/pci/pci.c	2004-12-02 14:30:02 -08:00
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
 #include <linux/spinlock.h>
+#include <linux/slab.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -36,7 +37,6 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
-
 #undef DEBUG
 #define DEBUG
 
@@ -48,6 +48,9 @@
 
 static int pci_routeirq;
 
+LIST_HEAD(pci_io_ranges);
+spinlock_t io_range_list_lock = SPIN_LOCK_UNLOCKED;
+
 /*
  * Low-level SAL-based PCI configuration access functions. Note that SAL
  * calls are already serialized (via sal_lock), so we don't need another
@@ -501,24 +504,35 @@
 pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 		     enum pci_mmap_state mmap_state, int write_combine)
 {
-	/*
-	 * I/O space cannot be accessed via normal processor loads and
-	 * stores on this platform.
-	 */
-	if (mmap_state == pci_mmap_io)
-		/*
-		 * XXX we could relax this for I/O spaces for which ACPI
-		 * indicates that the space is 1-to-1 mapped.  But at the
-		 * moment, we don't support multiple PCI address spaces and
-		 * the legacy I/O space is not 1-to-1 mapped, so this is moot.
-		 */
-		return -EINVAL;
+	struct io_range *new_range;
+	int ret = 0;
+	int iospace = (mmap_state == pci_mmap_io) ? 1 : 0;
+
+	/* Remap legacy I/O space for this bus if the offset is < 0xffff */
+	if (mmap_state == pci_mmap_io &&
+	    (vma->vm_pgoff << PAGE_SHIFT) < 0xffff) {
+		unsigned long legacy_io;
+		if ((ret = pci_get_legacy_space(iospace, dev, &legacy_io)))
+			goto out;
+
+		vma->vm_pgoff += legacy_io >> PAGE_SHIFT;
+	}
+
+	/* Remap legacy mem space for this bus if the offset is < 1M */
+	if (mmap_state == pci_mmap_mem &&
+	    (vma->vm_pgoff << PAGE_SHIFT) < (1024*1024)) {
+		unsigned long legacy_mem;
+		if ((ret = pci_get_legacy_space(iospace, dev, &legacy_mem)))
+			goto out;
+
+		vma->vm_pgoff += legacy_mem >> PAGE_SHIFT;
+	}
 
 	/*
 	 * Leave vm_pgoff as-is, the PCI space address is the physical
 	 * address on this platform.
 	 */
-	vma->vm_flags |= (VM_SHM | VM_LOCKED | VM_IO);
+	vma->vm_flags |= (VM_SHM | VM_IO | VM_RESERVED);
 
 	if (write_combine)
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
@@ -526,9 +540,78 @@
 		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 
 	if (remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
-			     vma->vm_end - vma->vm_start, vma->vm_page_prot))
-		return -EAGAIN;
+			    vma->vm_end - vma->vm_start, vma->vm_page_prot)) {
+		ret = -EAGAIN;
+		goto out;
+	}
 
+	new_range = kmalloc(sizeof(struct io_range), GFP_KERNEL);
+	if (!new_range) {
+		printk(KERN_WARNING "%s: cannot allocate io_range, "
+		       "I/O errors for 0x%016lx-0x%016lx will be fatal",
+		       __FUNCTION__, vma->vm_start, vma->vm_end);
+		goto out;
+	}
+
+	/*
+	 * Track this range and its associated process for use by the
+	 * MCA handler.
+	 */
+	new_range->start = __pa(vma->vm_pgoff << PAGE_SHIFT);
+	new_range->end = new_range->start + (vma->vm_end - vma->vm_start);
+	new_range->owner = current->pid;
+
+	spin_lock(&io_range_list_lock);
+	list_add(&new_range->range_list, &pci_io_ranges);
+	spin_unlock(&io_range_list_lock);
+
+	printk("I/O range 0x%016lx-0x%016lx registered\n",
+	       new_range->start, new_range->end);
+ out:
+	return ret;
+}
+
+/**
+ * pci_unmap_page_range - release any resources associated with a previous mapping
+ * @dev: pci device involved
+ *
+ * On ia64, this routine removes and frees the range in question from the
+ * io_range_list.
+ */
+void
+pci_mmap_release_dev(struct pci_dev *dev)
+{
+	struct io_range *range, *tmp;
+
+	spin_lock(&io_range_list_lock);
+	list_for_each_entry_safe(range, tmp, &pci_io_ranges, range_list) {
+		if (range->owner == current->pid) {
+			list_del(&range->range_list);
+			printk("I/O range 0x%016lx-0x%016lx de-registered\n",
+			       range->start, range->end);
+			kfree(range);
+		}
+	}
+	spin_unlock(&io_range_list_lock);
+}
+
+/**
+ * __ia64_pci_get_legacy_space - for machines w/o a machine vector
+ * @iospace: which space, I/O or memory
+ * @dev: pci dev
+ * @base: base address
+ *
+ * For most platforms, the legacy base address is 0, but platforms
+ * can override it by providing their own machine vector for this
+ * routine.  Note that platforms may want to provide their own routine
+ * even if the base is 0 in order to remap legacy space to the bus that
+ * @dev sits on.
+ */
+int
+__ia64_pci_get_legacy_space(int iospace, struct pci_dev *dev,
+				unsigned long *base)
+{
+	*base = 0;
 	return 0;
 }
 
===== arch/ia64/sn/pci/pci_dma.c 1.2 vs edited =====
--- 1.2/arch/ia64/sn/pci/pci_dma.c	2004-10-20 12:00:10 -07:00
+++ edited/arch/ia64/sn/pci/pci_dma.c	2004-12-01 10:44:54 -08:00
@@ -10,6 +10,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/pci.h>
 #include <asm/sn/sn_sal.h>
 #include "pci/pcibus_provider_defs.h"
 #include "pci/pcidev.h"
@@ -475,3 +476,19 @@
 EXPORT_SYMBOL(sn_pci_free_consistent);
 EXPORT_SYMBOL(sn_pci_dma_supported);
 EXPORT_SYMBOL(sn_dma_mapping_error);
+
+int sn_pci_get_legacy_space(int iospace, struct pci_dev *dev,
+			    unsigned long *base)
+{
+	if (SN_PCIDEV_BUSSOFT(dev) == NULL)
+		return -ENODEV;
+
+	if (iospace) {
+		/* Put the phys addr in uncached space */
+		*base = SN_PCIDEV_BUSSOFT(dev)->bs_legacy_io | __IA64_UNCACHED_OFFSET;
+	} else {
+		/* Put the phys addr in uncached space */
+		*base = SN_PCIDEV_BUSSOFT(dev)->bs_legacy_mem | __IA64_UNCACHED_OFFSET;
+	}
+	return 0;
+}
===== drivers/pci/proc.c 1.41 vs edited =====
--- 1.41/drivers/pci/proc.c	2004-10-06 09:44:51 -07:00
+++ edited/drivers/pci/proc.c	2004-12-01 10:13:26 -08:00
@@ -279,6 +279,10 @@
 
 static int proc_bus_pci_release(struct inode *inode, struct file *file)
 {
+	const struct proc_dir_entry *dp = PDE(inode);
+	struct pci_dev *dev = dp->data;
+
+	pci_mmap_release_dev(dev);
 	kfree(file->private_data);
 	file->private_data = NULL;
 
===== include/asm-ia64/io.h 1.24 vs edited =====
--- 1.24/include/asm-ia64/io.h	2004-10-28 12:10:56 -07:00
+++ edited/include/asm-ia64/io.h	2004-12-01 09:51:26 -08:00
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_IO_H
 #define _ASM_IA64_IO_H
 
+#include <linux/list.h>
+
 /*
  * This file contains the definitions for the emulated IO instructions
  * inb/inw/inl/outb/outw/outl and the "string versions" of the same
@@ -51,6 +53,17 @@
 extern struct io_space io_space[];
 extern unsigned int num_io_spaces;
 
+/*
+ * Simple I/O range object with owner (if there is one)
+ */
+struct io_range {
+	unsigned long start, end;
+	struct list_head range_list;
+	pid_t owner;
+};
+
+extern struct list_head pci_io_ranges;
+
 # ifdef __KERNEL__
 
 /*
@@ -66,11 +79,14 @@
 #define PIO_RESERVED		__IA64_UNCACHED_OFFSET
 #define HAVE_ARCH_PIO_SIZE
 
+#include <linux/spinlock.h>
 #include <asm/intrinsics.h>
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
 #include <asm-generic/iomap.h>
+
+extern spinlock_t io_range_list_lock;
 
 /*
  * Change virtual addresses to physical addresses and vv.
===== include/asm-ia64/machvec.h 1.29 vs edited =====
--- 1.29/include/asm-ia64/machvec.h	2004-10-25 13:06:49 -07:00
+++ edited/include/asm-ia64/machvec.h	2004-12-01 10:46:49 -08:00
@@ -20,6 +20,7 @@
 struct irq_desc;
 struct page;
 struct mm_struct;
+struct pci_dev;
 
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t (void);
@@ -31,6 +32,7 @@
 typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
 typedef u8 ia64_mv_irq_to_vector (unsigned int);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8);
+typedef int ia64_mv_pci_get_legacy_space_t (int, struct pci_dev *, unsigned long *);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
@@ -140,6 +142,7 @@
 #  define platform_readw_relaxed        ia64_mv.readw_relaxed
 #  define platform_readl_relaxed        ia64_mv.readl_relaxed
 #  define platform_readq_relaxed        ia64_mv.readq_relaxed
+#  define platform_pci_get_legacy_space	ia64_mv.pci_get_legacy_space
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
@@ -187,6 +190,7 @@
 	ia64_mv_readw_relaxed_t *readw_relaxed;
 	ia64_mv_readl_relaxed_t *readl_relaxed;
 	ia64_mv_readq_relaxed_t *readq_relaxed;
+	ia64_mv_pci_get_legacy_space_t *pci_get_legacy_space;
 } __attribute__((__aligned__(16))); /* align attrib? see above comment */
 
 #define MACHVEC_INIT(name)			\
@@ -230,6 +234,7 @@
 	platform_readw_relaxed,			\
 	platform_readl_relaxed,			\
 	platform_readq_relaxed,			\
+	platform_pci_get_legacy_space,	       	\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -374,6 +379,9 @@
 #endif
 #ifndef platform_readq_relaxed
 # define platform_readq_relaxed	__ia64_readq_relaxed
+#endif
+#ifndef platform_pci_get_legacy_space
+# define platform_pci_get_legacy_space __ia64_pci_get_legacy_space
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
===== include/asm-ia64/machvec_init.h 1.8 vs edited =====
--- 1.8/include/asm-ia64/machvec_init.h	2004-10-25 13:06:49 -07:00
+++ edited/include/asm-ia64/machvec_init.h	2004-12-01 10:55:12 -08:00
@@ -5,6 +5,7 @@
 extern ia64_mv_irq_desc __ia64_irq_desc;
 extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
+extern ia64_mv_pci_get_legacy_space_t __ia64_pci_get_legacy_space;
 
 extern ia64_mv_inb_t __ia64_inb;
 extern ia64_mv_inw_t __ia64_inw;
===== include/asm-ia64/machvec_sn2.h 1.16 vs edited =====
--- 1.16/include/asm-ia64/machvec_sn2.h	2004-10-25 13:06:49 -07:00
+++ edited/include/asm-ia64/machvec_sn2.h	2004-12-01 10:42:03 -08:00
@@ -70,6 +70,7 @@
 extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
 extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
+extern ia64_mv_pci_get_legacy_space_t	sn_pci_get_legacy_space;
 
 /*
  * This stuff has dual use!
@@ -118,6 +119,7 @@
 #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
 #define platform_dma_mapping_error		sn_dma_mapping_error
 #define platform_dma_supported		sn_dma_supported
+#define platform_pci_get_legacy_space	sn_pci_get_legacy_space
 
 #include <asm/sn/io.h>
 
===== include/asm-ia64/pci.h 1.27 vs edited =====
--- 1.27/include/asm-ia64/pci.h	2004-11-03 13:36:55 -08:00
+++ edited/include/asm-ia64/pci.h	2004-12-01 10:53:19 -08:00
@@ -85,6 +85,8 @@
 #define HAVE_PCI_MMAP
 extern int pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 				enum pci_mmap_state mmap_state, int write_combine);
+extern void pci_mmap_release_dev (struct pci_dev *dev);
+#define pci_get_legacy_space platform_pci_get_legacy_space
 
 struct pci_window {
 	struct resource resource;

--Boundary-00=_UeJsBnmRpuUhdRo--
