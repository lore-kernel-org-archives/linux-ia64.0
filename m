From: Horms <horms@verge.net.au>
Date: Wed, 30 Aug 2006 08:27:13 +0000
Subject: Re: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <20060830082712.GA21244@verge.net.au>
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

Hi,

Below is an incremental version of your patch relative to the
the V3 version that you posted about 10 days ago.

The entire series for Tony Luck's ia64-test and 2.6.18-rc5 can be found at:
http://www.vergenet.net/~horms/patches/ia64-kexec/kernel/

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

IA64: kexec/kdump 2.6.18-rc5 patch

> Archived-At: <http://permalink.gmane.org/gmane.linux.ports.ia64/14761>
> 
> Hi,
> 	Below is the IA64 kexec/kdump patch against 2.6.18-rc5.
> 
> Fixes and enhancements in this patch include:
> 
> 1. Fix I/D cache coherence problem.
>    Kdump sometimes hit an I/D cache coherence issue on platform with
>    separate I/D cache.  Although there is fc.i instruction in
>    relocate_kernel.S.  purgatory code and the second kernel code is copy
>    into reserved region at kexec_load when running "kexec -p".  There
>    need and an icache_flush when segments is copied into its destination.
> 2. Change elf_prstatus to an per_cpu value to save stack size at crash
> path according 
>    to Bob Montgomery's suggestion.
> 3. put AP to a loop of hint.pause instead of call pal_halt_light.
> 
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Incremental version of the above patch

CC: Zou Nan hai <nanhai.zou@intel.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/crash.c |   18 +++++++++++-------
 arch/ia64/kernel/smp.c   |    3 ++-
 include/asm-ia64/kexec.h |    5 +++++
 include/linux/kexec.h    |    5 +++++
 kernel/kexec.c           |    1 +
 5 files changed, 24 insertions(+), 8 deletions(-)

Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2006-08-30 16:47:25.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2006-08-30 16:47:38.000000000 +0900
@@ -72,16 +72,20 @@
 
 extern void ia64_dump_cpu_regs(void *);
 
+static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
+
 void
 crash_save_this_cpu()
 {
 	void *buf;
-	struct elf_prstatus prstatus;
-	int cpu = smp_processor_id();
 	unsigned long cfm, sof, sol;
-	elf_greg_t *dst = (elf_greg_t *)&prstatus.pr_reg;
-	memset(&prstatus, 0, sizeof(prstatus));
-	prstatus.pr_pid = current->pid;
+
+	int cpu = smp_processor_id();
+	struct elf_prstatus *prstatus = &per_cpu(elf_prstatus, cpu);
+
+	elf_greg_t *dst = (elf_greg_t *)&(prstatus->pr_reg);
+	memset(prstatus, 0, sizeof(*prstatus));
+	prstatus->pr_pid = current->pid;
 
 	ia64_dump_cpu_regs(dst);
         cfm = dst[43];
@@ -93,8 +97,8 @@
         buf = (u64 *) per_cpu_ptr(crash_notes, cpu);
 	if (!buf)
 		return;
-	buf = append_elf_note(buf, "CORE", NT_PRSTATUS, &prstatus,
-		sizeof(prstatus));
+	buf = append_elf_note(buf, "CORE", NT_PRSTATUS, prstatus,
+		sizeof(*prstatus));
 	final_note(buf);
 }
 
Index: linux-2.6/arch/ia64/kernel/smp.c
=================================--- linux-2.6.orig/arch/ia64/kernel/smp.c	2006-08-30 16:47:25.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/smp.c	2006-08-30 16:47:38.000000000 +0900
@@ -133,7 +133,8 @@
 	local_irq_disable();
 	crash_save_this_cpu();
 	current->thread.ksp = (__u64)info->sw - 16;
-	cpu_halt();
+	for (;;)
+                ia64_hint(ia64_hint_pause);
 }
 #endif
 
Index: linux-2.6/include/asm-ia64/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2006-08-30 16:47:25.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2006-08-30 16:47:38.000000000 +0900
@@ -20,6 +20,11 @@
 #define vmlpt_bits	(impl_va_bits - PAGE_SHIFT + pte_bits)
 #define POW2(n)		(1ULL << (n))
 
+#define kexec_flush_icache_page(page) do { \
+                unsigned long page_addr = (unsigned long)page_address(page); \
+                flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
+        } while(0)
+
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
 const extern unsigned int relocate_new_kernel_size;
 volatile extern long kexec_rendez;
Index: linux-2.6/include/linux/kexec.h
=================================--- linux-2.6.orig/include/linux/kexec.h	2006-08-30 16:45:50.000000000 +0900
+++ linux-2.6/include/linux/kexec.h	2006-08-30 16:47:38.000000000 +0900
@@ -108,6 +108,10 @@
 extern struct kimage *kexec_image;
 extern struct kimage *kexec_crash_image;
 
+#ifndef kexec_flush_icache_page
+#define kexec_flush_icache_page(page)
+#endif
+
 #define KEXEC_ON_CRASH  0x00000001
 #define KEXEC_ARCH_MASK 0xffff0000
 
@@ -131,6 +135,7 @@
 typedef u32 note_buf_t[MAX_NOTE_BYTES/4];
 extern note_buf_t *crash_notes;
 
+
 #else /* !CONFIG_KEXEC */
 struct pt_regs;
 struct task_struct;
Index: linux-2.6/kernel/kexec.c
=================================--- linux-2.6.orig/kernel/kexec.c	2006-08-30 16:45:50.000000000 +0900
+++ linux-2.6/kernel/kexec.c	2006-08-30 16:47:38.000000000 +0900
@@ -851,6 +851,7 @@
 			memset(ptr + uchunk, 0, mchunk - uchunk);
 		}
 		result = copy_from_user(ptr, buf, uchunk);
+		kexec_flush_icache_page(page);
 		kunmap(page);
 		if (result) {
 			result = (result < 0) ? result : -EIO;
