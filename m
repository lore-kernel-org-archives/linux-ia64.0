From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 12 May 2004 19:03:28 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405121203.28506.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_AUnoApOSbXLGXx6"
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_AUnoApOSbXLGXx6
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday, May 4, 2004 11:04 am, Jesse Barnes wrote:
> Ok, I'll keep hacking on it then and post a patch when I have something
> presentable.

Well, maybe this isn't quite presentable, but it seems to work for my small 
test cases.  The basic idea is that when a user land process mmaps something 
in /proc/bus/pci, it'll get added to a list which is checked by the MCA 
handler when a bus check occurs.  If there's a match, the process is 
SIGBUS'd.

There are still lots of holes I think, especially since I'm not sure about all 
of the MCA specific bits yet.  In particular, is looking at the current MCA 
record ok?  Should I be indexing into ->proc_err.info any further than I do?  
There are also locking problems, since at the moment an MCA could occur on 
multiple processors, but I think the MCA code in general doesn't handle that 
case...

Anyway, I'd appreciate any comments.  Maybe something like this is ok for the 
mainline?  I haven't dealt with read_check here, but I think the pseudocode 
would be something like this:

read_check(addr) {
  val = *addr;
  PAL_MC_DRAIN;
  if (dev->error_flag)
     return error;
  return val;
}

Obviously, error_flag would be set in the MCA code as well based on walking 
the PCI resource structures looking for a match with the target identifier 
that caused the MCA...

Jesse

--Boundary-00=_AUnoApOSbXLGXx6
Content-Type: text/plain;
  charset="iso-8859-1";
  name="io-error-sigbus.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="io-error-sigbus.patch"

===== arch/ia64/kernel/mca.c 1.60 vs edited =====
--- 1.60/arch/ia64/kernel/mca.c	Mon Mar  1 06:43:35 2004
+++ edited/arch/ia64/kernel/mca.c	Wed May 12 11:33:24 2004
@@ -797,13 +797,51 @@
 void
 ia64_mca_ucmc_handler(void)
 {
+	struct io_range *range;
+	unsigned long io_addr = 0;
 	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
 		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover = psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
+	int recover = 0;
+	ia64_err_rec_t *curr_record;
 
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
+	/* TLB errors are fixed up before we get here, so recover */
+	if (psp->tc) {
+		recover = 1;
+		goto return_to_sal;
+	}
+
+	/*
+	 * If it's not a bus check with a valid target identifier,
+	 * we don't have a chance.
+	 */
+	if (!psp->bc) {// || !curr_record->proc_err.info->valid.target_identifier) {
+		recover = 0;
+		goto return_to_sal;
+	}
+
+	curr_record = IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA);
+	io_addr = curr_record->proc_err.info->target_identifier;
+
+	/*
+	 * See if an I/O error occured in a previously registered range
+	 */
+	list_for_each_entry(range, &pci_io_ranges, range_list) {
+		if (range->start <= io_addr && io_addr <= range->end) {
+			struct siginfo siginfo;
+			recover = 1;
+			siginfo.si_signo = SIGBUS;
+			siginfo.si_code = BUS_ADRERR;
+			siginfo.si_addr  = (void *) io_addr;
+			force_sig_info(SIGBUS, &siginfo,
+				       find_task_by_pid(range->owner));
+			break;
+		}
+	}
+
+return_to_sal:
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
 	 *  loop.
===== arch/ia64/pci/pci.c 1.48 vs edited =====
--- 1.48/arch/ia64/pci/pci.c	Wed Apr 21 14:26:09 2004
+++ edited/arch/ia64/pci/pci.c	Wed May 12 10:56:16 2004
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
 #include <linux/spinlock.h>
+#include <linux/slab.h>
 
 #include <asm/machvec.h>
 #include <asm/page.h>
@@ -48,6 +49,9 @@
 
 struct pci_fixup pcibios_fixups[1];
 
+LIST_HEAD(pci_io_ranges);
+spinlock_t io_range_list_lock = SPIN_LOCK_UNLOCKED;
+
 /*
  * Low-level SAL-based PCI configuration access functions. Note that SAL
  * calls are already serialized (via sal_lock), so we don't need another
@@ -437,6 +441,8 @@
 pci_mmap_page_range (struct pci_dev *dev, struct vm_area_struct *vma,
 		     enum pci_mmap_state mmap_state, int write_combine)
 {
+	struct io_range *new_range;
+
 	/*
 	 * I/O space cannot be accessed via normal processor loads and stores on this
 	 * platform.
@@ -465,6 +471,29 @@
 			     vma->vm_end - vma->vm_start, vma->vm_page_prot))
 		return -EAGAIN;
 
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
 	return 0;
 }
 
===== drivers/pci/proc.c 1.38 vs edited =====
--- 1.38/drivers/pci/proc.c	Fri Mar 26 08:11:04 2004
+++ edited/drivers/pci/proc.c	Wed May 12 11:46:04 2004
@@ -279,8 +279,22 @@
 
 static int proc_bus_pci_release(struct inode *inode, struct file *file)
 {
+	struct io_range *range;
+
 	kfree(file->private_data);
 	file->private_data = NULL;
+
+	spin_lock(&io_range_list_lock);
+	list_for_each_entry(range, &pci_io_ranges, range_list) {
+		if (range->owner == current->pid) {
+			list_del(&range->range_list);
+			printk("I/O range 0x%016lx-0x%016lx de-registered\n",
+			       range->start, range->end);
+			kfree(range);
+			break;
+		}
+	}
+	spin_unlock(&io_range_list_lock);
 
 	return 0;
 }
===== include/asm-ia64/io.h 1.19 vs edited =====
--- 1.19/include/asm-ia64/io.h	Tue Feb  3 21:31:10 2004
+++ edited/include/asm-ia64/io.h	Tue May  4 10:02:55 2004
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_IO_H
 #define _ASM_IA64_IO_H
 
+#include <linux/list.h>
+
 /*
  * This file contains the definitions for the emulated IO instructions
  * inb/inw/inl/outb/outw/outl and the "string versions" of the same
@@ -50,12 +52,26 @@
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
 
+#include <linux/spinlock.h>
 #include <asm/intrinsics.h>
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/system.h>
+
+extern spinlock_t io_range_list_lock;
 
 /*
  * Change virtual addresses to physical addresses and vv.

--Boundary-00=_AUnoApOSbXLGXx6--
