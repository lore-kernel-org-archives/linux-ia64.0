From: Simon Horman <horms@verge.net.au>
Date: Tue, 08 May 2007 09:31:17 +0000
Subject: [patch 3/3] Use generic elf code on ia64
Message-Id: <20070508093329.295451195@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070508093114.767199973@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fastboot@lists.osdl.org, kexec@lists.infradead.org, linux-ia64@vger.kernel.org
Cc: Nanhai Zou <nanhai.zou@intel.com>, Vivek Goyal <vgoyal@in.ibm.com>, Tony Luck <tony.luck@intel.com>

Make use of the generic implementation of crash_save_cpu().

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

* Updated crash_save_cpu() to use a per-cpu variable for the registers.
  As requested by Nanhai Zou

* Added CC: kexec@lists.infradead.org, which is the new place for kexec
  discussion.

* Split per-cpu prstatus and kdump_elf_core_copy_regs() macro changes
  into two separate patches

 linux-2.6/arch/ia64/kernel/crash.c         |   46 +---------------------------
 linux-2.6/arch/ia64/kernel/machine_kexec.c |    2 -
 linux-2.6/include/asm-ia64/kexec.h         |    7 +++-
 3 files changed, 10 insertions(+), 45 deletions(-)

Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2007-04-25 17:31:54.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2007-04-25 17:31:55.000000000 +0900
@@ -25,44 +25,11 @@ static atomic_t kdump_cpu_frozen;
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
@@ -70,13 +37,6 @@ crash_save_this_cpu(void)
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
@@ -134,7 +94,7 @@ kdump_cpu_freeze(struct unw_frame_info *
 	int cpuid;
 	local_irq_disable();
 	cpuid = smp_processor_id();
-	crash_save_this_cpu();
+	crash_save_cpu(NULL, smp_processor_id());
 	current->thread.ksp = (__u64)info->sw - 16;
 	atomic_inc(&kdump_cpu_frozen);
 	kdump_status[cpuid] = 1;
Index: linux-2.6/include/asm-ia64/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2007-04-25 17:31:54.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2007-04-25 17:31:55.000000000 +0900
@@ -19,6 +19,9 @@
                 flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
         } while(0)
 
+#define kexec_elf_core_copy_regs(elfregs, regs) \
+	ia64_kexec_elf_core_copy_regs(elfregs, regs)
+
 extern struct kimage *ia64_kimage;
 extern const unsigned int relocate_new_kernel_size;
 extern void relocate_new_kernel(unsigned long, unsigned long,
@@ -32,7 +35,9 @@ extern struct resource boot_param_res;
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
Index: linux-2.6/arch/ia64/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/ia64/kernel/machine_kexec.c	2007-04-25 17:31:54.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/machine_kexec.c	2007-04-25 17:31:55.000000000 +0900
@@ -84,7 +84,7 @@ static void ia64_machine_kexec(struct un
 
 	BUG_ON(!image);
 	if (image->type = KEXEC_TYPE_CRASH) {
-		crash_save_this_cpu();
+		crash_save_cpu(NULL, smp_processor_id());
 		current->thread.ksp = (__u64)info->sw - 16;
 	}
 

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

