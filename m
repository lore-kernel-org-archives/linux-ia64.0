From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 03 Jul 2003 05:19:09 +0000
Subject: Re: kernel update (relative to 2.4.21)
Message-Id: <marc-linux-ia64-105720964726091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105716647121510@msgid-missing>
In-Reply-To: <marc-linux-ia64-105716647121510@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2 Jul 2003 11:08:36 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.21-ia64-030702.diff.gz

Trivial patch to remove warnings about unused variables and functions
befing used before they are defined.

Index: 21.7/arch/ia64/kernel/smpboot.c
--- 21.7/arch/ia64/kernel/smpboot.c Sun, 18 May 2003 15:06:40 +1000 kaos (linux-2.4/r/c/37_smpboot.c 1.1.3.1.3.1.1.6 644)
+++ 21.7(w)/arch/ia64/kernel/smpboot.c Thu, 03 Jul 2003 14:34:19 +1000 kaos (linux-2.4/r/c/37_smpboot.c 1.1.3.1.3.1.1.6 644)
@@ -320,6 +320,7 @@ smp_callin (void)
 {
 	int cpuid, phys_id;
 	extern void ia64_init_itm(void);
+	extern void ia64_cpu_local_tick(void);
 
 #ifdef CONFIG_PERFMON
 	extern void pfm_init_percpu(void);
Index: 21.7/arch/ia64/kernel/setup.c
--- 21.7/arch/ia64/kernel/setup.c Thu, 03 Jul 2003 12:05:08 +1000 kaos (linux-2.4/r/c/48_setup.c 1.1.3.1.3.1.2.8 644)
+++ 21.7(w)/arch/ia64/kernel/setup.c Thu, 03 Jul 2003 14:32:42 +1000 kaos (linux-2.4/r/c/48_setup.c 1.1.3.1.3.1.2.8 644)
@@ -32,6 +32,10 @@
 #include <linux/ioport.h>
 #include <linux/efi.h>
 
+#ifdef CONFIG_BLK_DEV_RAM
+# include <linux/blk.h>
+#endif
+
 #include <asm/ia32.h>
 #include <asm/page.h>
 #include <asm/machvec.h>
@@ -42,10 +46,6 @@
 #include <asm/smp.h>
 #include <asm/tlb.h>
 
-#ifdef CONFIG_BLK_DEV_RAM
-# include <linux/blk.h>
-#endif
-
 #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
 # error "struct cpuinfo_ia64 too big!"
 #endif
Index: 21.7/arch/ia64/kernel/process.c
--- 21.7/arch/ia64/kernel/process.c Thu, 03 Jul 2003 12:05:08 +1000 kaos (linux-2.4/r/c/50_process.c 1.1.3.1.3.1.2.2.1.5 644)
+++ 21.7(w)/arch/ia64/kernel/process.c Thu, 03 Jul 2003 14:23:52 +1000 kaos (linux-2.4/r/c/50_process.c 1.1.3.1.3.1.2.2.1.5 644)
@@ -56,12 +56,6 @@ ia64_do_show_stack (struct unw_frame_inf
 }
 
 void
-show_trace_task (struct task_struct *task)
-{
-	show_stack(task);
-}
-
-void
 show_stack (struct task_struct *task)
 {
 	if (!task)
@@ -75,6 +69,12 @@ show_stack (struct task_struct *task)
 }
 
 void
+show_trace_task (struct task_struct *task)
+{
+	show_stack(task);
+}
+
+void
 show_regs (struct pt_regs *regs)
 {
 	unsigned long ip = regs->cr_iip + ia64_psr(regs)->ri;
Index: 21.7/arch/ia64/kernel/perfmon.c
--- 21.7/arch/ia64/kernel/perfmon.c Sun, 18 May 2003 15:06:40 +1000 kaos (linux-2.4/r/c/51_perfmon.c 1.1.3.2.3.1.1.1.1.4 644)
+++ 21.7(w)/arch/ia64/kernel/perfmon.c Thu, 03 Jul 2003 14:25:23 +1000 kaos (linux-2.4/r/c/51_perfmon.c 1.1.3.2.3.1.1.1.1.4 644)
@@ -447,7 +447,9 @@ static struct {
  * forward declarations
  */
 static void pfm_reset_pmu(struct task_struct *);
+#ifndef CONFIG_SMP
 static unsigned long pfm_lazy_save_regs (struct task_struct *ta);
+#endif
 
 #if   defined(CONFIG_ITANIUM)
 #include "perfmon_itanium.h"
Index: 21.7/arch/ia64/kernel/pci.c
--- 21.7/arch/ia64/kernel/pci.c Thu, 03 Jul 2003 12:05:08 +1000 kaos (linux-2.4/s/c/0_pci.c 1.1.2.1.3.1.1.10 644)
+++ 21.7(w)/arch/ia64/kernel/pci.c Thu, 03 Jul 2003 14:50:21 +1000 kaos (linux-2.4/s/c/0_pci.c 1.1.2.1.3.1.1.10 644)
@@ -390,9 +390,6 @@ pcibios_config_init (void)
 void __init
 pcibios_init (void)
 {
-	int i = 0;
-	struct pci_controller *controller;
-
 #ifdef CONFIG_IA64_MCA
 	ia64_mca_check_errors();    /* For post-failure MCA error logging */
 #endif
Index: 21.7/arch/ia64/kernel/acpi.c
--- 21.7/arch/ia64/kernel/acpi.c Sun, 18 May 2003 15:06:40 +1000 kaos (linux-2.4/s/c/18_acpi.c 1.1.3.1.3.1.1.1.1.4 644)
+++ 21.7(w)/arch/ia64/kernel/acpi.c Thu, 03 Jul 2003 14:49:20 +1000 kaos (linux-2.4/s/c/18_acpi.c 1.1.3.1.3.1.1.1.1.4 644)
@@ -179,7 +179,6 @@ acpi_hp_csr_space(acpi_handle obj, u64 *
 	acpi_status status;
 	u8 *data;
 	u32 length;
-	int i;
 
 	status = acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data, &length);
 
Index: 21.7/arch/ia64/kernel/salinfo.c
--- 21.7/arch/ia64/kernel/salinfo.c Thu, 03 Jul 2003 12:05:08 +1000 kaos (linux-2.4/K/g/22_salinfo.c 1.2 644)
+++ 21.7(w)/arch/ia64/kernel/salinfo.c Thu, 03 Jul 2003 14:50:01 +1000 kaos (linux-2.4/K/g/22_salinfo.c 1.2 644)
@@ -98,9 +98,6 @@ salinfo_log_wakeup(int type)
 static int
 salinfo_event_open(struct inode *inode, struct file *file)
 {
-	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
-	struct salinfo_event *event = entry->data;
-
 	if (!suser())
 		return -EPERM;
 	return 0;

