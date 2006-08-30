From: Horms <horms@verge.net.au>
Date: Wed, 30 Aug 2006 08:27:08 +0000
Subject: Re: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <20060830082705.GA21261@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156837594.2598.15.camel@linux-znh>
In-Reply-To: <1156837594.2598.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 30 Aug 2006 06:03:23 +0800, Zou Nan hai wrote:
> On Wed, 2006-08-30 at 03:38, Bjorn Helgaas wrote:
>> On Tuesday 29 August 2006 01:46, Zou Nan hai wrote:
>> > +#ifdef CONFIG_KEXEC
>> > +void
>> > +ioc_iova_disable(void)
>> > +{
>> 
>> Ugh.  If you really need this functionality (which I have to say
>> looks
>> like a band-aid), it probably should be a platform vector.  And
>> should
>> be split into a separate patch.
>> 
> Hi Bjorn,
>        The ioc_iova_disable code comes from Aziz in HP, I have almost
>        no idea
> of how IOMMU works on HP platform.
> I am looking for an HP machine with IOMMU to test. 

Below are some minor cleanups against your latest patch.
In particular the bogus kernel/irq/manage.c fragment is eliminated.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

IA64: kexec whitespace and 80 column fixes

Signed-OFf-By: Simon Horman <horms@verge.net.au>

 arch/ia64/hp/common/sba_iommu.c  |    6 ++++--
 arch/ia64/kernel/crash.c         |    6 +++---
 arch/ia64/kernel/efi.c           |    6 ++++--
 arch/ia64/kernel/iosapic.c       |    5 ++---
 arch/ia64/kernel/machine_kexec.c |   20 ++++++++++++--------
 arch/ia64/kernel/smp.c           |    2 +-
 include/linux/kexec.h            |    1 -
 kernel/irq/manage.c              |    1 +
 8 files changed, 27 insertions(+), 20 deletions(-)

Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2006-08-30 16:48:14.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2006-08-30 16:58:02.000000000 +0900
@@ -57,9 +57,10 @@
 	/* Pre-load control code buffer to minimize work in kexec path */
 	control_code_buffer = page_address(image->control_code_page);
 	memcpy((void *)control_code_buffer, (const void *)func[0],
-			relocate_new_kernel_size);
+	       relocate_new_kernel_size);
 	flush_icache_range((unsigned long)control_code_buffer,
-			(unsigned long)control_code_buffer + relocate_new_kernel_size);
+   			   (unsigned long)control_code_buffer +
+   			   relocate_new_kernel_size);
 	ia64_kimage = image;
 
 	return 0;
@@ -81,14 +82,16 @@
 		}
 	}
 #elif defined(CONFIG_SMP)
-	smp_call_function(kexec_stop_this_cpu, (void *)ia64_kimage->start, 0, 0);
+	smp_call_function(kexec_stop_this_cpu, (void *)ia64_kimage->start,
+			  0, 0);
 #endif
 #ifdef CONFIG_PCI
 	{
 		struct pci_dev *dev = NULL;
 		irq_desc_t *idesc;
 		/* Disable all PCI devices */
-		while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
+		while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev))
+		       != NULL) {
 			if (!(dev->is_enabled))
 				continue;
 			idesc = irq_desc + dev->irq;
@@ -112,12 +115,13 @@
  * We are past the point of no return, committed to rebooting now.
  */
 extern void *efi_get_pal_addr(void);
-static void ia64_machine_kexec(struct unw_frame_info *info, void *arg) 
+static void ia64_machine_kexec(struct unw_frame_info *info, void *arg)
 {
 	struct kimage *image = arg;
 	relocate_new_kernel_t rnk;
 	void *pal_addr = efi_get_pal_addr();
-	unsigned long code_addr = (unsigned long)page_address(image->control_code_page);
+	unsigned long code_addr = (unsigned long)
+				  page_address(image->control_code_page);
 	if (image->type = KEXEC_TYPE_CRASH) {
 		crash_save_this_cpu();
 		current->thread.ksp = (__u64)info->sw - 16;
@@ -128,9 +132,9 @@
 	local_irq_disable();
 	rnk = (relocate_new_kernel_t)&code_addr;
 	(*rnk)(image->head, image->start, ia64_boot_param,
-		     GRANULEROUNDDOWN((unsigned long) pal_addr));
+	       GRANULEROUNDDOWN((unsigned long) pal_addr));
 	BUG();
-} 
+}
 
 void machine_kexec(struct kimage *image)
 {
Index: linux-2.6/arch/ia64/kernel/smp.c
=================================--- linux-2.6.orig/arch/ia64/kernel/smp.c	2006-08-30 16:48:15.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/smp.c	2006-08-30 16:52:21.000000000 +0900
@@ -127,7 +127,7 @@
 }
 
 #ifdef CONFIG_CRASH_DUMP
-static void 
+static void
 kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
 {
 	local_irq_disable();
Index: linux-2.6/include/linux/kexec.h
=================================--- linux-2.6.orig/include/linux/kexec.h	2006-08-30 16:48:33.000000000 +0900
+++ linux-2.6/include/linux/kexec.h	2006-08-30 16:49:48.000000000 +0900
@@ -135,7 +135,6 @@
 typedef u32 note_buf_t[MAX_NOTE_BYTES/4];
 extern note_buf_t *crash_notes;
 
-
 #else /* !CONFIG_KEXEC */
 struct pt_regs;
 struct task_struct;
Index: linux-2.6/arch/ia64/hp/common/sba_iommu.c
=================================--- linux-2.6.orig/arch/ia64/hp/common/sba_iommu.c	2006-08-30 16:53:08.000000000 +0900
+++ linux-2.6/arch/ia64/hp/common/sba_iommu.c	2006-08-30 16:54:21.000000000 +0900
@@ -1633,11 +1633,13 @@
 
 	while (ioc != NULL) {
 		/* Disable IOVA translation */
-		WRITE_REG(ioc->ibase & 0xfffffffffffffffe, ioc->ioc_hpa + IOC_IBASE);
+		WRITE_REG(ioc->ibase & 0xfffffffffffffffe,
+			  ioc->ioc_hpa + IOC_IBASE);
 		READ_REG(ioc->ioc_hpa + IOC_IBASE);
 
 		/* Clear I/O TLB of any possible entries */
-		WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) + iovp_shift), ioc->ioc_hpa + IOC_PCOM);
+		WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) +
+					iovp_shift), ioc->ioc_hpa + IOC_PCOM);
 		READ_REG(ioc->ioc_hpa + IOC_PCOM);
 
 		ioc = ioc->next;
Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2006-08-30 16:53:08.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2006-08-30 16:55:28.000000000 +0900
@@ -24,7 +24,7 @@
 #include <asm/uaccess.h>
 
 size_t copy_oldmem_page(unsigned long pfn, char *buf,
-                               size_t csize, unsigned long offset, int userbuf)
+			size_t csize, unsigned long offset, int userbuf)
 {
         void  *vaddr;
 
@@ -50,7 +50,7 @@
 
 static inline Elf64_Word
 *append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
-		size_t data_len)
+ 		 size_t data_len)
 {
 	struct elf_note *note = (struct elf_note *)buf;
 	note->n_namesz = strlen(name) + 1;
@@ -92,7 +92,7 @@
         sol = (cfm >> 7) & 0x7f;
         sof = cfm & 0x7f;
         dst[46] = (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
-                        sof - sol);
+				    		    sof - sol);
 
         buf = (u64 *) per_cpu_ptr(crash_notes, cpu);
 	if (!buf)
Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2006-08-30 16:53:08.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2006-08-30 16:55:55.000000000 +0900
@@ -432,9 +432,11 @@
 		}
 	}
 	if (min_addr != 0UL)
-		printk(KERN_INFO "Ignoring memory below %luMB\n", min_addr >> 20);
+		printk(KERN_INFO "Ignoring memory below %luMB\n",
+		       min_addr >> 20);
 	if (max_addr != ~0UL)
-		printk(KERN_INFO "Ignoring memory above %luMB\n", max_addr >> 20);
+		printk(KERN_INFO "Ignoring memory above %luMB\n",
+		       max_addr >> 20);
 
 	efi.systab = __va(ia64_boot_param->efi_systab);
 
Index: linux-2.6/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.orig/arch/ia64/kernel/iosapic.c	2006-08-30 16:53:08.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/iosapic.c	2006-08-30 16:56:45.000000000 +0900
@@ -298,10 +298,9 @@
 	for (info = iosapic_intr_info; info <
 			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
 		low32 = info->low32 |= IOSAPIC_MASK;
-		list_for_each_entry(rte, &info->rtes,
-				rte_list) {
+		list_for_each_entry(rte, &info->rtes, rte_list) {
 			iosapic_write(rte->addr,
-					IOSAPIC_RTE_LOW(rte->rte_index), low32);
+				      IOSAPIC_RTE_LOW(rte->rte_index), low32);
 		}
 	}
 }
Index: linux-2.6/kernel/irq/manage.c
=================================--- linux-2.6.orig/kernel/irq/manage.c	2006-08-30 16:53:08.000000000 +0900
+++ linux-2.6/kernel/irq/manage.c	2006-08-30 17:00:10.000000000 +0900
@@ -475,3 +475,4 @@
 	return retval;
 }
 EXPORT_SYMBOL(request_irq);
+
