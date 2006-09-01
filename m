From: Horms <horms@verge.net.au>
Date: Fri, 01 Sep 2006 02:24:51 +0000
Subject: Re: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <20060901022449.GA30838@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1156837594.2598.15.camel@linux-znh>
In-Reply-To: <1156837594.2598.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Aug 30, 2006 at 05:27:08PM +0900, Horms wrote:
> On 30 Aug 2006 06:03:23 +0800, Zou Nan hai wrote:
> > On Wed, 2006-08-30 at 03:38, Bjorn Helgaas wrote:
> >> On Tuesday 29 August 2006 01:46, Zou Nan hai wrote:
> >> > +#ifdef CONFIG_KEXEC
> >> > +void
> >> > +ioc_iova_disable(void)
> >> > +{
> >> 
> >> Ugh.  If you really need this functionality (which I have to say
> >> looks
> >> like a band-aid), it probably should be a platform vector.  And
> >> should
> >> be split into a separate patch.
> >> 
> > Hi Bjorn,
> >        The ioc_iova_disable code comes from Aziz in HP, I have almost
> >        no idea
> > of how IOMMU works on HP platform.
> > I am looking for an HP machine with IOMMU to test. 
> 
> Below are some minor cleanups against your latest patch.
> In particular the bogus kernel/irq/manage.c fragment is eliminated.

Jes Sorensen pointed out to me that the kernel/irq/manage.c fragment of
the previous version of this patch introduces a bogus blank line - and
nothing else. This new version rectifies that problem.

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
 7 files changed, 26 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index aa4ef60..178e800 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1633,11 +1633,13 @@ ioc_iova_disable(void)
 
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
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index aa63c47..ae9d4ce 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -24,7 +24,7 @@ #include <linux/device.h>
 #include <asm/uaccess.h>
 
 size_t copy_oldmem_page(unsigned long pfn, char *buf,
-                               size_t csize, unsigned long offset, int userbuf)
+			size_t csize, unsigned long offset, int userbuf)
 {
         void  *vaddr;
 
@@ -50,7 +50,7 @@ #endif
 
 static inline Elf64_Word
 *append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
-		size_t data_len)
+ 		 size_t data_len)
 {
 	struct elf_note *note = (struct elf_note *)buf;
 	note->n_namesz = strlen(name) + 1;
@@ -92,7 +92,7 @@ crash_save_this_cpu()
         sol = (cfm >> 7) & 0x7f;
         sof = cfm & 0x7f;
         dst[46] = (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
-                        sof - sol);
+				    		    sof - sol);
 
         buf = (u64 *) per_cpu_ptr(crash_notes, cpu);
 	if (!buf)
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 6935452..ae4a115 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -432,9 +432,11 @@ efi_init (void)
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
 
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 9e9367a..9a3d0bf 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -298,10 +298,9 @@ kdump_disable_iosapic(void)
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
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 9deff9a..65b084f 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -57,9 +57,10 @@ int machine_kexec_prepare(struct kimage 
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
@@ -81,14 +82,16 @@ #ifdef CONFIG_HOTPLUG_CPU
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
@@ -112,12 +115,13 @@ #endif
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
@@ -128,9 +132,9 @@ static void ia64_machine_kexec(struct un
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
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 154903d..0a4a763 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -127,7 +127,7 @@ stop_this_cpu (void)
 }
 
 #ifdef CONFIG_CRASH_DUMP
-static void 
+static void
 kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
 {
 	local_irq_disable();
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 75fbb7e..c790e08 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -135,7 +135,6 @@ extern struct resource crashk_res;
 typedef u32 note_buf_t[MAX_NOTE_BYTES/4];
 extern note_buf_t *crash_notes;
 
-
 #else /* !CONFIG_KEXEC */
 struct pt_regs;
 struct task_struct;
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
