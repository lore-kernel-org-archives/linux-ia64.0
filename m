From: Simon Horman <horms@verge.net.au>
Date: Mon, 16 Apr 2007 08:21:06 +0000
Subject: Re: [PATCH] kexec/kdump: Use generic elf code on ia64
Message-Id: <20070416082104.GA13376@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070416074103.GA27981@verge.net.au>
In-Reply-To: <20070416074103.GA27981@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make use of the generic implementation of crash_save_cpu().

On ia64 the registers are saved by a kdump-specific function
ia64_dump_cpu_regs() rather than elf_core_copy_regs() which 
is used by other architectures via crash_save_cpu(). It seems
that ia64_dump_cpu_regs() and elf_core_copy_regs() are indeed
quite different

In order to facilitate this kdump_elf_core_copy_regs()
has been created, and it is called by crash_save_cpu().
By default kdump_elf_core_copy_regs() is just defined to be
elf_core_copy_regs() and ia64 defines its own implementation,
which calls ia64_dump_cpu_regs().  The ia64 version also sets
register 47 in accordance with the code that it replaces.

The code appears to work, however as the place where the registers
are captured has changed natrually some of their values have also changed.
This makes looking for problems by comparing the new and old output a
little tricky.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
* This patch applies on top of the note size calculation patch
  that can be found in mm and at
  http://lists.linux-foundation.org/pipermail/fastboot/2007-April/006792.html

  Porting this patch to not require that one is quite trivial.
  I can supply a port or a thread containing both patches if it helps.

* Update
  Diff against include/asm-ia64/kexec.h instead of include/asm/kexec.h
  Ooops!

 arch/ia64/kernel/crash.c         |   46 ++------------------------------------
 arch/ia64/kernel/machine_kexec.c |    2 -
 include/asm-ia64/kexec.h              |    7 ++++-
 include/linux/kexec.h            |    5 ++++
 kernel/kexec.c                   |    2 -
 5 files changed, 16 insertions(+), 46 deletions(-)

Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2007-04-16 16:13:57.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2007-04-16 16:14:52.000000000 +0900
@@ -25,44 +25,11 @@
 atomic_t kdump_in_progress;
 static int kdump_on_init = 1;
 
-static inline Elf64_Word
-*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
-		size_t data_len)
-{
-	struct elf_note *note = (struct elf_note *)buf;
-	note->n_namesz = strlen(name) + 1;
-	note->n_descsz = data_len;
-	note->n_type   = type;
-	buf += (sizeof(*note) + 3)/4;
-	memcpy(buf, name, note->n_namesz);
-	buf += (note->n_namesz + 3)/4;
-	memcpy(buf, data, data_len);
-	buf += (data_len + 3)/4;
-	return buf;
-}
-
-static void
-final_note(void *buf)
-{
-	memset(buf, 0, sizeof(struct elf_note));
-}
-
-extern void ia64_dump_cpu_regs(void *);
-
-static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
-
 void
-crash_save_this_cpu(void)
+ia64_kexec_elf_core_copy_regs(elf_gregset_t *elfregs, struct pt_regs *regs)
 {
-	void *buf;
 	unsigned long cfm, sof, sol;
-
-	int cpu = smp_processor_id();
-	struct elf_prstatus *prstatus = &per_cpu(elf_prstatus, cpu);
-
-	elf_greg_t *dst = (elf_greg_t *)&(prstatus->pr_reg);
-	memset(prstatus, 0, sizeof(*prstatus));
-	prstatus->pr_pid = current->pid;
+	elf_greg_t *dst = (elf_greg_t *)elfregs;
 
 	ia64_dump_cpu_regs(dst);
 	cfm = dst[43];
@@ -70,13 +37,6 @@
 	sof = cfm & 0x7f;
 	dst[46] = (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
 			sof - sol);
-
-	buf = (u64 *) per_cpu_ptr(crash_notes, cpu);
-	if (!buf)
-		return;
-	buf = append_elf_note(buf, KEXEC_CORE_NOTE_NAME, NT_PRSTATUS, prstatus,
-			sizeof(*prstatus));
-	final_note(buf);
 }
 
 #ifdef CONFIG_SMP
@@ -134,7 +94,7 @@
 	int cpuid;
 	local_irq_disable();
 	cpuid = smp_processor_id();
-	crash_save_this_cpu();
+	crash_save_cpu(NULL, smp_processor_id());
 	current->thread.ksp = (__u64)info->sw - 16;
 	atomic_inc(&kdump_cpu_frozen);
 	kdump_status[cpuid] = 1;
Index: linux-2.6/include/asm/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2007-04-16 16:13:57.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2007-04-16 16:14:52.000000000 +0900
@@ -19,6 +19,9 @@
                 flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
         } while(0)
 
+#define kexec_elf_core_copy_regs(elfregs, regs) \
+	ia64_kexec_elf_core_copy_regs(elfregs, regs)
+
 extern struct kimage *ia64_kimage;
 extern const unsigned int relocate_new_kernel_size;
 extern void relocate_new_kernel(unsigned long, unsigned long,
@@ -32,7 +35,9 @@
 extern void kdump_smp_send_stop(void);
 extern void kdump_smp_send_init(void);
 extern void kexec_disable_iosapic(void);
-extern void crash_save_this_cpu(void);
+extern void ia64_dump_cpu_regs(void *);
+extern void ia64_kexec_elf_core_copy_regs(elf_gregset_t *elfregs,
+					  struct pt_regs *regs);
 struct rsvd_region;
 extern unsigned long kdump_find_rsvd_region(unsigned long size,
 		struct rsvd_region *rsvd_regions, int n);
Index: linux-2.6/include/linux/kexec.h
=================================--- linux-2.6.orig/include/linux/kexec.h	2007-04-16 16:13:57.000000000 +0900
+++ linux-2.6/include/linux/kexec.h	2007-04-16 16:14:52.000000000 +0900
@@ -128,6 +128,11 @@
 #define kexec_flush_icache_page(page)
 #endif
 
+#ifndef kexec_elf_core_copy_regs
+#define kexec_elf_core_copy_regs(elfregs, regs) \
+	elf_core_copy_regs(elfregs, regs)
+#endif
+
 #define KEXEC_ON_CRASH  0x00000001
 #define KEXEC_ARCH_MASK 0xffff0000
 
Index: linux-2.6/kernel/kexec.c
=================================--- linux-2.6.orig/kernel/kexec.c	2007-04-16 16:13:57.000000000 +0900
+++ linux-2.6/kernel/kexec.c	2007-04-16 16:14:52.000000000 +0900
@@ -1117,7 +1117,7 @@
 		return;
 	memset(&prstatus, 0, sizeof(prstatus));
 	prstatus.pr_pid = current->pid;
-	elf_core_copy_regs(&prstatus.pr_reg, regs);
+	kexec_elf_core_copy_regs(&prstatus.pr_reg, regs);
 	buf = append_elf_note(buf, KEXEC_CORE_NOTE_NAME, NT_PRSTATUS,
 		      	      &prstatus, sizeof(prstatus));
 	final_note(buf);
Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2007-04-16 16:11:23.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2007-04-16 16:14:52.000000000 +0900
@@ -84,7 +84,7 @@
 
 	BUG_ON(!image);
 	if (image->type = KEXEC_TYPE_CRASH) {
-		crash_save_this_cpu();
+		crash_save_cpu(NULL, smp_processor_id());
 		current->thread.ksp = (__u64)info->sw - 16;
 	}
 
