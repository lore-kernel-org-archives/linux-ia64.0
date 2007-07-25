From: Len Brown <lenb@kernel.org>
Date: Wed, 25 Jul 2007 06:22:41 +0000
Subject: Fwd: [PATCH 16/16] ACPI: Kconfig: remove CONFIG_ACPI_SLEEP from source
Message-Id: <200707250222.44616.lenb@kernel.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_0wupGz3wYEW6fPF"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_0wupGz3wYEW6fPF
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

FYI,
I got rid of CONFIG_ACPI_SLEEP b/c it caused more
trouble than it was worth -- people disabling it by mistake...

Seemed simpler to drop a couple of stubs into IA64
than to have a bunch of CONFIG_ACPI_SLEEP #ifdefs.

Also, when IA64 adds sleep support, we'll be that
much closer to ready for it.

cheers,
-Len

ps. this depends on some patches earlier in this series on the linux-acpi list.

----------  Forwarded Message  ----------

Subject: [PATCH 16/16] ACPI: Kconfig: remove CONFIG_ACPI_SLEEP from source
Date: Wednesday 25 July 2007 01:51
From: Len Brown <len.brown@intel.com>
To: linux-acpi@vger.kernel.org
Cc: Len Brown <len.brown@intel.com>

As it was a synonym for (CONFIG_ACPI && CONFIG_X86),
the ifdefs for it were more clutter than they were worth.

For ia64, just add a few stubs in anticipation of future
S3 or S4 support.

Signed-off-by: Len Brown <len.brown@intel.com>
---
 arch/i386/kernel/acpi/Makefile   |    2 +-
 arch/i386/kernel/setup.c         |    2 +-
 arch/i386/mm/init.c              |    2 +-
 arch/ia64/kernel/acpi.c          |   19 +++++++++++++++++++
 arch/x86_64/kernel/acpi/Makefile |    2 +-
 arch/x86_64/kernel/acpi/sleep.c  |    4 ----
 arch/x86_64/kernel/head.S        |    2 +-
 arch/x86_64/kernel/setup.c       |    2 +-
 drivers/acpi/Kconfig             |   10 +++-------
 drivers/acpi/sleep/Makefile      |    4 ++--
 drivers/acpi/sleep/main.c        |    2 ++
 drivers/acpi/sleep/poweroff.c    |    2 --
 drivers/acpi/sleep/wakeup.c      |    2 --
 include/acpi/acpi_drivers.h      |    4 ----
 include/asm-i386/acpi.h          |   23 +++++++++--------------
 include/asm-i386/suspend.h       |    2 +-
 include/asm-ia64/acpi.h          |    5 +++++
 include/asm-x86_64/acpi.h        |   22 +++++++++-------------
 include/asm-x86_64/suspend.h     |    2 --
 kernel/sysctl.c                  |    2 +-
 20 files changed, 57 insertions(+), 58 deletions(-)

diff --git a/arch/i386/kernel/acpi/Makefile b/arch/i386/kernel/acpi/Makefile
index 7f7be01..223f58f 100644
--- a/arch/i386/kernel/acpi/Makefile
+++ b/arch/i386/kernel/acpi/Makefile
@@ -2,7 +2,7 @@ obj-$(CONFIG_ACPI)		+= boot.o
 ifneq ($(CONFIG_PCI),)
 obj-$(CONFIG_X86_IO_APIC)	+= earlyquirk.o
 endif
-obj-$(CONFIG_ACPI_SLEEP)	+= sleep.o wakeup.o
+obj-$(CONFIG_ACPI)		+= sleep.o wakeup.o
 
 ifneq ($(CONFIG_ACPI_PROCESSOR),)
 obj-y				+= cstate.o processor.o
diff --git a/arch/i386/kernel/setup.c b/arch/i386/kernel/setup.c
index d474cd6..7fe5da3 100644
--- a/arch/i386/kernel/setup.c
+++ b/arch/i386/kernel/setup.c
@@ -422,7 +422,7 @@ void __init setup_bootmem_allocator(void)
 	 */
 	reserve_bootmem(PAGE_SIZE, PAGE_SIZE);
 #endif
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
 	/*
 	 * Reserve low memory region for sleep support.
 	 */
diff --git a/arch/i386/mm/init.c b/arch/i386/mm/init.c
index c3b9905..1b1a1e6 100644
--- a/arch/i386/mm/init.c
+++ b/arch/i386/mm/init.c
@@ -432,7 +432,7 @@ static void __init pagetable_init (void)
 	paravirt_pagetable_setup_done(pgd_base);
 }
 
-#if defined(CONFIG_SOFTWARE_SUSPEND) || defined(CONFIG_ACPI_SLEEP)
+#if defined(CONFIG_SOFTWARE_SUSPEND) || defined(CONFIG_ACPI)
 /*
  * Swap suspend & friends need this for resume because things like the intel-agp
  * driver might have split up a kernel 4MB mapping.
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 103dd8e..c6ede87 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -67,6 +67,8 @@ EXPORT_SYMBOL(pm_power_off);
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
+unsigned long acpi_wakeup_address = 0;
+
 const char __init *
 acpi_get_sysname(void)
 {
@@ -986,4 +988,21 @@ int acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
 
 EXPORT_SYMBOL(acpi_unregister_ioapic);
 
+/*
+ * acpi_save_state_mem() - save kernel state
+ *
+ * TBD when when IA64 starts to support suspend...
+ */
+int acpi_save_state_mem(void) { return 0; } 
+
+/*
+ * acpi_restore_state()
+ */
+void acpi_restore_state_mem(void) {}
+
+/*
+ * do_suspend_lowlevel()
+ */
+void do_suspend_lowlevel(void) {}
+
 #endif				/* CONFIG_ACPI */
diff --git a/arch/x86_64/kernel/acpi/Makefile b/arch/x86_64/kernel/acpi/Makefile
index 080b996..17595d2 100644
--- a/arch/x86_64/kernel/acpi/Makefile
+++ b/arch/x86_64/kernel/acpi/Makefile
@@ -1,6 +1,6 @@
 obj-y			:= boot.o
 boot-y			:= ../../../i386/kernel/acpi/boot.o
-obj-$(CONFIG_ACPI_SLEEP)	+= sleep.o wakeup.o
+obj-y			+= sleep.o wakeup.o
 
 ifneq ($(CONFIG_ACPI_PROCESSOR),)
 obj-y			+= processor.o
diff --git a/arch/x86_64/kernel/acpi/sleep.c b/arch/x86_64/kernel/acpi/sleep.c
index 4277f2b..79475d2 100644
--- a/arch/x86_64/kernel/acpi/sleep.c
+++ b/arch/x86_64/kernel/acpi/sleep.c
@@ -51,8 +51,6 @@
                               Low-Level Sleep Support
    -------------------------------------------------------------------------- */
 
-#ifdef CONFIG_ACPI_SLEEP
-
 /* address in low memory of the wakeup routine. */
 unsigned long acpi_wakeup_address = 0;
 unsigned long acpi_realmode_flags;
@@ -117,8 +115,6 @@ static int __init acpi_sleep_setup(char *str)
 
 __setup("acpi_sleep=", acpi_sleep_setup);
 
-#endif				/*CONFIG_ACPI_SLEEP */
-
 void acpi_pci_link_exit(void)
 {
 }
diff --git a/arch/x86_64/kernel/head.S b/arch/x86_64/kernel/head.S
index e89abcd..3a16e41 100644
--- a/arch/x86_64/kernel/head.S
+++ b/arch/x86_64/kernel/head.S
@@ -120,7 +120,7 @@ ident_complete:
 	addq	%rbp, trampoline_level4_pgt + 0(%rip)
 	addq	%rbp, trampoline_level4_pgt + (511*8)(%rip)
 #endif
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
 	addq	%rbp, wakeup_level4_pgt + 0(%rip)
 	addq	%rbp, wakeup_level4_pgt + (511*8)(%rip)
 #endif
diff --git a/arch/x86_64/kernel/setup.c b/arch/x86_64/kernel/setup.c
index af838f6..0f400f3 100644
--- a/arch/x86_64/kernel/setup.c
+++ b/arch/x86_64/kernel/setup.c
@@ -333,7 +333,7 @@ void __init setup_arch(char **cmdline_p)
 	reserve_bootmem_generic(SMP_TRAMPOLINE_BASE, 2*PAGE_SIZE);
 #endif
 
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
        /*
         * Reserve low memory region for sleep support.
         */
diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 524cbf1..251344c 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -11,6 +11,9 @@ menuconfig ACPI
 	depends on PCI
 	depends on PM
 	select PNP
+	# for sleep
+	select HOTPLUG_CPU if X86 && SMP
+	select SUSPEND_SMP if X86 && SMP
 	default y
 	---help---
 	  Advanced Configuration and Power Interface (ACPI) support for 
@@ -42,13 +45,6 @@ menuconfig ACPI
 
 if ACPI
 
-config ACPI_SLEEP
-	bool
-	depends on X86
-	select HOTPLUG_CPU if SMP
-	select SUSPEND_SMP if SMP
-	default y
-
 config ACPI_PROCFS
 	bool "Deprecated /proc/acpi files"
 	depends on PROC_FS
diff --git a/drivers/acpi/sleep/Makefile b/drivers/acpi/sleep/Makefile
index 195a4f6..01a993a 100644
--- a/drivers/acpi/sleep/Makefile
+++ b/drivers/acpi/sleep/Makefile
@@ -1,5 +1,5 @@
 obj-y					:= poweroff.o wakeup.o
-obj-$(CONFIG_ACPI_SLEEP)		+= main.o
-obj-$(CONFIG_ACPI_SLEEP)		+= proc.o
+obj-y					+= main.o
+obj-$(CONFIG_X86)			+= proc.o
 
 EXTRA_CFLAGS += $(ACPI_CFLAGS)
diff --git a/drivers/acpi/sleep/main.c b/drivers/acpi/sleep/main.c
index 3279e72..54c2dfc 100644
--- a/drivers/acpi/sleep/main.c
+++ b/drivers/acpi/sleep/main.c
@@ -136,10 +136,12 @@ static int acpi_pm_finish(suspend_state_t pm_state)
 	/* reset firmware waking vector */
 	acpi_set_firmware_waking_vector((acpi_physical_address) 0);
 
+#ifdef CONFIG_X86
 	if (init_8259A_after_S1) {
 		printk("Broken toshiba laptop -> kicking interrupts\n");
 		init_8259A(0);
 	}
+#endif
 	return 0;
 }
 
diff --git a/drivers/acpi/sleep/poweroff.c b/drivers/acpi/sleep/poweroff.c
index 39e40d5..b3f68ef 100644
--- a/drivers/acpi/sleep/poweroff.c
+++ b/drivers/acpi/sleep/poweroff.c
@@ -18,7 +18,6 @@
 
 int acpi_sleep_prepare(u32 acpi_state)
 {
-#ifdef CONFIG_ACPI_SLEEP
 	/* do we have a wakeup address for S2 and S3? */
 	if (acpi_state == ACPI_STATE_S3) {
 		if (!acpi_wakeup_address) {
@@ -31,7 +30,6 @@ int acpi_sleep_prepare(u32 acpi_state)
 	}
 	ACPI_FLUSH_CPU_CACHE();
 	acpi_enable_wakeup_device_prep(acpi_state);
-#endif
 	acpi_gpe_sleep_prepare(acpi_state);
 	acpi_enter_sleep_state_prep(acpi_state);
 	return 0;
diff --git a/drivers/acpi/sleep/wakeup.c b/drivers/acpi/sleep/wakeup.c
index fab8f26..97c27dd 100644
--- a/drivers/acpi/sleep/wakeup.c
+++ b/drivers/acpi/sleep/wakeup.c
@@ -17,7 +17,6 @@ ACPI_MODULE_NAME("wakeup_devices")
 extern struct list_head acpi_wakeup_device_list;
 extern spinlock_t acpi_device_lock;
 
-#ifdef CONFIG_ACPI_SLEEP
 /**
  * acpi_enable_wakeup_device_prep - prepare wakeup devices
  *	@sleep_state:	ACPI state
@@ -180,7 +179,6 @@ static int __init acpi_wakeup_device_init(void)
 }
 
 late_initcall(acpi_wakeup_device_init);
-#endif
 
 /*
  * Disable all wakeup GPEs before entering requested sleep state.
diff --git a/include/acpi/acpi_drivers.h b/include/acpi/acpi_drivers.h
index 5535159..07b5d76 100644
--- a/include/acpi/acpi_drivers.h
+++ b/include/acpi/acpi_drivers.h
@@ -142,10 +142,6 @@ static inline void unregister_hotplug_dock_device(acpi_handle handle)
 /*--------------------------------------------------------------------------
                                   Suspend/Resume
   -------------------------------------------------------------------------- */
-#ifdef CONFIG_ACPI_SLEEP
 extern int acpi_sleep_init(void);
-#else
-#define acpi_sleep_init() do {} while (0)
-#endif
 
 #endif /*__ACPI_DRIVERS_H__*/
diff --git a/include/asm-i386/acpi.h b/include/asm-i386/acpi.h
index 449f3f2..125179a 100644
--- a/include/asm-i386/acpi.h
+++ b/include/asm-i386/acpi.h
@@ -121,19 +121,6 @@ static inline void acpi_disable_pci(void)
 }
 extern int acpi_irq_balance_set(char *str);
 
-#else	/* !CONFIG_ACPI */
-
-#define acpi_lapic 0
-#define acpi_ioapic 0
-static inline void acpi_noirq_set(void) { }
-static inline void acpi_disable_pci(void) { }
-static inline void disable_acpi(void) { }
-
-#endif	/* !CONFIG_ACPI */
-
-
-#ifdef CONFIG_ACPI_SLEEP
-
 /* routines for saving/restoring kernel state */
 extern int acpi_save_state_mem(void);
 extern void acpi_restore_state_mem(void);
@@ -143,7 +130,15 @@ extern unsigned long acpi_wakeup_address;
 /* early initialization routine */
 extern void acpi_reserve_bootmem(void);
 
-#endif /*CONFIG_ACPI_SLEEP*/
+#else	/* !CONFIG_ACPI */
+
+#define acpi_lapic 0
+#define acpi_ioapic 0
+static inline void acpi_noirq_set(void) { }
+static inline void acpi_disable_pci(void) { }
+static inline void disable_acpi(void) { }
+
+#endif	/* !CONFIG_ACPI */
 
 #define ARCH_HAS_POWER_INIT	1
 
diff --git a/include/asm-i386/suspend.h b/include/asm-i386/suspend.h
index 8dbaafe..a252073 100644
--- a/include/asm-i386/suspend.h
+++ b/include/asm-i386/suspend.h
@@ -21,7 +21,7 @@ struct saved_context {
 	unsigned long return_address;
 } __attribute__((packed));
 
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
 extern unsigned long saved_eip;
 extern unsigned long saved_esp;
 extern unsigned long saved_ebp;
diff --git a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
index 5b52635..49730ff 100644
--- a/include/asm-ia64/acpi.h
+++ b/include/asm-ia64/acpi.h
@@ -100,6 +100,11 @@ const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
 int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
+/* routines for saving/restoring kernel state */
+extern int acpi_save_state_mem(void);
+extern void acpi_restore_state_mem(void);
+extern unsigned long acpi_wakeup_address;
+
 /*
  * Record the cpei override flag and current logical cpu. This is
  * useful for CPU removal.
diff --git a/include/asm-x86_64/acpi.h b/include/asm-x86_64/acpi.h
index 1da8f49..9817335 100644
--- a/include/asm-x86_64/acpi.h
+++ b/include/asm-x86_64/acpi.h
@@ -108,6 +108,15 @@ static inline void acpi_disable_pci(void)
 }
 extern int acpi_irq_balance_set(char *str);
 
+/* routines for saving/restoring kernel state */
+extern int acpi_save_state_mem(void);
+extern void acpi_restore_state_mem(void);
+
+extern unsigned long acpi_wakeup_address;
+
+/* early initialization routine */
+extern void acpi_reserve_bootmem(void);
+
 #else	/* !CONFIG_ACPI */
 
 #define acpi_lapic 0
@@ -121,19 +130,6 @@ extern int acpi_numa;
 extern int acpi_scan_nodes(unsigned long start, unsigned long end);
 #define NR_NODE_MEMBLKS (MAX_NUMNODES*2)
 
-#ifdef CONFIG_ACPI_SLEEP
-
-/* routines for saving/restoring kernel state */
-extern int acpi_save_state_mem(void);
-extern void acpi_restore_state_mem(void);
-
-extern unsigned long acpi_wakeup_address;
-
-/* early initialization routine */
-extern void acpi_reserve_bootmem(void);
-
-#endif /*CONFIG_ACPI_SLEEP*/
-
 extern int acpi_disabled;
 extern int acpi_pci_disabled;
 
diff --git a/include/asm-x86_64/suspend.h b/include/asm-x86_64/suspend.h
index 9c3f8de..b897e8c 100644
--- a/include/asm-x86_64/suspend.h
+++ b/include/asm-x86_64/suspend.h
@@ -44,7 +44,6 @@ extern unsigned long saved_context_eflags;
 
 extern void fix_processor_context(void);
 
-#ifdef CONFIG_ACPI_SLEEP
 extern unsigned long saved_rip;
 extern unsigned long saved_rsp;
 extern unsigned long saved_rbp;
@@ -54,4 +53,3 @@ extern unsigned long saved_rdi;
 
 /* routines for saving/restoring kernel state */
 extern int acpi_save_state_mem(void);
-#endif
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ddebf3f..eb26f2b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -689,7 +689,7 @@ static ctl_table kern_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
-#ifdef CONFIG_ACPI_SLEEP
+#if defined(CONFIG_ACPI) && defined(CONFIG_X86)
 	{
 		.ctl_name	= KERN_ACPI_VIDEO_FLAGS,
 		.procname	= "acpi_video_flags",
-- 
1.5.3.rc2.22.g69a9b
-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


-------------------------------------------------------

--Boundary-00=_0wupGz3wYEW6fPF
Content-Type: text/plain;
  name="[PATCH 16/16] ACPI: Kconfig: remove CONFIG_ACPI_SLEEP from source"
Content-Transfer-Encoding: 7bit

As it was a synonym for (CONFIG_ACPI && CONFIG_X86),
the ifdefs for it were more clutter than they were worth.

For ia64, just add a few stubs in anticipation of future
S3 or S4 support.

Signed-off-by: Len Brown <len.brown@intel.com>
---
 arch/i386/kernel/acpi/Makefile   |    2 +-
 arch/i386/kernel/setup.c         |    2 +-
 arch/i386/mm/init.c              |    2 +-
 arch/ia64/kernel/acpi.c          |   19 +++++++++++++++++++
 arch/x86_64/kernel/acpi/Makefile |    2 +-
 arch/x86_64/kernel/acpi/sleep.c  |    4 ----
 arch/x86_64/kernel/head.S        |    2 +-
 arch/x86_64/kernel/setup.c       |    2 +-
 drivers/acpi/Kconfig             |   10 +++-------
 drivers/acpi/sleep/Makefile      |    4 ++--
 drivers/acpi/sleep/main.c        |    2 ++
 drivers/acpi/sleep/poweroff.c    |    2 --
 drivers/acpi/sleep/wakeup.c      |    2 --
 include/acpi/acpi_drivers.h      |    4 ----
 include/asm-i386/acpi.h          |   23 +++++++++--------------
 include/asm-i386/suspend.h       |    2 +-
 include/asm-ia64/acpi.h          |    5 +++++
 include/asm-x86_64/acpi.h        |   22 +++++++++-------------
 include/asm-x86_64/suspend.h     |    2 --
 kernel/sysctl.c                  |    2 +-
 20 files changed, 57 insertions(+), 58 deletions(-)

diff --git a/arch/i386/kernel/acpi/Makefile b/arch/i386/kernel/acpi/Makefile
index 7f7be01..223f58f 100644
--- a/arch/i386/kernel/acpi/Makefile
+++ b/arch/i386/kernel/acpi/Makefile
@@ -2,7 +2,7 @@ obj-$(CONFIG_ACPI)		+= boot.o
 ifneq ($(CONFIG_PCI),)
 obj-$(CONFIG_X86_IO_APIC)	+= earlyquirk.o
 endif
-obj-$(CONFIG_ACPI_SLEEP)	+= sleep.o wakeup.o
+obj-$(CONFIG_ACPI)		+= sleep.o wakeup.o
 
 ifneq ($(CONFIG_ACPI_PROCESSOR),)
 obj-y				+= cstate.o processor.o
diff --git a/arch/i386/kernel/setup.c b/arch/i386/kernel/setup.c
index d474cd6..7fe5da3 100644
--- a/arch/i386/kernel/setup.c
+++ b/arch/i386/kernel/setup.c
@@ -422,7 +422,7 @@ void __init setup_bootmem_allocator(void)
 	 */
 	reserve_bootmem(PAGE_SIZE, PAGE_SIZE);
 #endif
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
 	/*
 	 * Reserve low memory region for sleep support.
 	 */
diff --git a/arch/i386/mm/init.c b/arch/i386/mm/init.c
index c3b9905..1b1a1e6 100644
--- a/arch/i386/mm/init.c
+++ b/arch/i386/mm/init.c
@@ -432,7 +432,7 @@ static void __init pagetable_init (void)
 	paravirt_pagetable_setup_done(pgd_base);
 }
 
-#if defined(CONFIG_SOFTWARE_SUSPEND) || defined(CONFIG_ACPI_SLEEP)
+#if defined(CONFIG_SOFTWARE_SUSPEND) || defined(CONFIG_ACPI)
 /*
  * Swap suspend & friends need this for resume because things like the intel-agp
  * driver might have split up a kernel 4MB mapping.
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 103dd8e..c6ede87 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -67,6 +67,8 @@ EXPORT_SYMBOL(pm_power_off);
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
+unsigned long acpi_wakeup_address = 0;
+
 const char __init *
 acpi_get_sysname(void)
 {
@@ -986,4 +988,21 @@ int acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
 
 EXPORT_SYMBOL(acpi_unregister_ioapic);
 
+/*
+ * acpi_save_state_mem() - save kernel state
+ *
+ * TBD when when IA64 starts to support suspend...
+ */
+int acpi_save_state_mem(void) { return 0; } 
+
+/*
+ * acpi_restore_state()
+ */
+void acpi_restore_state_mem(void) {}
+
+/*
+ * do_suspend_lowlevel()
+ */
+void do_suspend_lowlevel(void) {}
+
 #endif				/* CONFIG_ACPI */
diff --git a/arch/x86_64/kernel/acpi/Makefile b/arch/x86_64/kernel/acpi/Makefile
index 080b996..17595d2 100644
--- a/arch/x86_64/kernel/acpi/Makefile
+++ b/arch/x86_64/kernel/acpi/Makefile
@@ -1,6 +1,6 @@
 obj-y			:= boot.o
 boot-y			:= ../../../i386/kernel/acpi/boot.o
-obj-$(CONFIG_ACPI_SLEEP)	+= sleep.o wakeup.o
+obj-y			+= sleep.o wakeup.o
 
 ifneq ($(CONFIG_ACPI_PROCESSOR),)
 obj-y			+= processor.o
diff --git a/arch/x86_64/kernel/acpi/sleep.c b/arch/x86_64/kernel/acpi/sleep.c
index 4277f2b..79475d2 100644
--- a/arch/x86_64/kernel/acpi/sleep.c
+++ b/arch/x86_64/kernel/acpi/sleep.c
@@ -51,8 +51,6 @@
                               Low-Level Sleep Support
    -------------------------------------------------------------------------- */
 
-#ifdef CONFIG_ACPI_SLEEP
-
 /* address in low memory of the wakeup routine. */
 unsigned long acpi_wakeup_address = 0;
 unsigned long acpi_realmode_flags;
@@ -117,8 +115,6 @@ static int __init acpi_sleep_setup(char *str)
 
 __setup("acpi_sleep=", acpi_sleep_setup);
 
-#endif				/*CONFIG_ACPI_SLEEP */
-
 void acpi_pci_link_exit(void)
 {
 }
diff --git a/arch/x86_64/kernel/head.S b/arch/x86_64/kernel/head.S
index e89abcd..3a16e41 100644
--- a/arch/x86_64/kernel/head.S
+++ b/arch/x86_64/kernel/head.S
@@ -120,7 +120,7 @@ ident_complete:
 	addq	%rbp, trampoline_level4_pgt + 0(%rip)
 	addq	%rbp, trampoline_level4_pgt + (511*8)(%rip)
 #endif
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
 	addq	%rbp, wakeup_level4_pgt + 0(%rip)
 	addq	%rbp, wakeup_level4_pgt + (511*8)(%rip)
 #endif
diff --git a/arch/x86_64/kernel/setup.c b/arch/x86_64/kernel/setup.c
index af838f6..0f400f3 100644
--- a/arch/x86_64/kernel/setup.c
+++ b/arch/x86_64/kernel/setup.c
@@ -333,7 +333,7 @@ void __init setup_arch(char **cmdline_p)
 	reserve_bootmem_generic(SMP_TRAMPOLINE_BASE, 2*PAGE_SIZE);
 #endif
 
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
        /*
         * Reserve low memory region for sleep support.
         */
diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 524cbf1..251344c 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -11,6 +11,9 @@ menuconfig ACPI
 	depends on PCI
 	depends on PM
 	select PNP
+	# for sleep
+	select HOTPLUG_CPU if X86 && SMP
+	select SUSPEND_SMP if X86 && SMP
 	default y
 	---help---
 	  Advanced Configuration and Power Interface (ACPI) support for 
@@ -42,13 +45,6 @@ menuconfig ACPI
 
 if ACPI
 
-config ACPI_SLEEP
-	bool
-	depends on X86
-	select HOTPLUG_CPU if SMP
-	select SUSPEND_SMP if SMP
-	default y
-
 config ACPI_PROCFS
 	bool "Deprecated /proc/acpi files"
 	depends on PROC_FS
diff --git a/drivers/acpi/sleep/Makefile b/drivers/acpi/sleep/Makefile
index 195a4f6..01a993a 100644
--- a/drivers/acpi/sleep/Makefile
+++ b/drivers/acpi/sleep/Makefile
@@ -1,5 +1,5 @@
 obj-y					:= poweroff.o wakeup.o
-obj-$(CONFIG_ACPI_SLEEP)		+= main.o
-obj-$(CONFIG_ACPI_SLEEP)		+= proc.o
+obj-y					+= main.o
+obj-$(CONFIG_X86)			+= proc.o
 
 EXTRA_CFLAGS += $(ACPI_CFLAGS)
diff --git a/drivers/acpi/sleep/main.c b/drivers/acpi/sleep/main.c
index 3279e72..54c2dfc 100644
--- a/drivers/acpi/sleep/main.c
+++ b/drivers/acpi/sleep/main.c
@@ -136,10 +136,12 @@ static int acpi_pm_finish(suspend_state_t pm_state)
 	/* reset firmware waking vector */
 	acpi_set_firmware_waking_vector((acpi_physical_address) 0);
 
+#ifdef CONFIG_X86
 	if (init_8259A_after_S1) {
 		printk("Broken toshiba laptop -> kicking interrupts\n");
 		init_8259A(0);
 	}
+#endif
 	return 0;
 }
 
diff --git a/drivers/acpi/sleep/poweroff.c b/drivers/acpi/sleep/poweroff.c
index 39e40d5..b3f68ef 100644
--- a/drivers/acpi/sleep/poweroff.c
+++ b/drivers/acpi/sleep/poweroff.c
@@ -18,7 +18,6 @@
 
 int acpi_sleep_prepare(u32 acpi_state)
 {
-#ifdef CONFIG_ACPI_SLEEP
 	/* do we have a wakeup address for S2 and S3? */
 	if (acpi_state == ACPI_STATE_S3) {
 		if (!acpi_wakeup_address) {
@@ -31,7 +30,6 @@ int acpi_sleep_prepare(u32 acpi_state)
 	}
 	ACPI_FLUSH_CPU_CACHE();
 	acpi_enable_wakeup_device_prep(acpi_state);
-#endif
 	acpi_gpe_sleep_prepare(acpi_state);
 	acpi_enter_sleep_state_prep(acpi_state);
 	return 0;
diff --git a/drivers/acpi/sleep/wakeup.c b/drivers/acpi/sleep/wakeup.c
index fab8f26..97c27dd 100644
--- a/drivers/acpi/sleep/wakeup.c
+++ b/drivers/acpi/sleep/wakeup.c
@@ -17,7 +17,6 @@ ACPI_MODULE_NAME("wakeup_devices")
 extern struct list_head acpi_wakeup_device_list;
 extern spinlock_t acpi_device_lock;
 
-#ifdef CONFIG_ACPI_SLEEP
 /**
  * acpi_enable_wakeup_device_prep - prepare wakeup devices
  *	@sleep_state:	ACPI state
@@ -180,7 +179,6 @@ static int __init acpi_wakeup_device_init(void)
 }
 
 late_initcall(acpi_wakeup_device_init);
-#endif
 
 /*
  * Disable all wakeup GPEs before entering requested sleep state.
diff --git a/include/acpi/acpi_drivers.h b/include/acpi/acpi_drivers.h
index 5535159..07b5d76 100644
--- a/include/acpi/acpi_drivers.h
+++ b/include/acpi/acpi_drivers.h
@@ -142,10 +142,6 @@ static inline void unregister_hotplug_dock_device(acpi_handle handle)
 /*--------------------------------------------------------------------------
                                   Suspend/Resume
   -------------------------------------------------------------------------- */
-#ifdef CONFIG_ACPI_SLEEP
 extern int acpi_sleep_init(void);
-#else
-#define acpi_sleep_init() do {} while (0)
-#endif
 
 #endif /*__ACPI_DRIVERS_H__*/
diff --git a/include/asm-i386/acpi.h b/include/asm-i386/acpi.h
index 449f3f2..125179a 100644
--- a/include/asm-i386/acpi.h
+++ b/include/asm-i386/acpi.h
@@ -121,19 +121,6 @@ static inline void acpi_disable_pci(void)
 }
 extern int acpi_irq_balance_set(char *str);
 
-#else	/* !CONFIG_ACPI */
-
-#define acpi_lapic 0
-#define acpi_ioapic 0
-static inline void acpi_noirq_set(void) { }
-static inline void acpi_disable_pci(void) { }
-static inline void disable_acpi(void) { }
-
-#endif	/* !CONFIG_ACPI */
-
-
-#ifdef CONFIG_ACPI_SLEEP
-
 /* routines for saving/restoring kernel state */
 extern int acpi_save_state_mem(void);
 extern void acpi_restore_state_mem(void);
@@ -143,7 +130,15 @@ extern unsigned long acpi_wakeup_address;
 /* early initialization routine */
 extern void acpi_reserve_bootmem(void);
 
-#endif /*CONFIG_ACPI_SLEEP*/
+#else	/* !CONFIG_ACPI */
+
+#define acpi_lapic 0
+#define acpi_ioapic 0
+static inline void acpi_noirq_set(void) { }
+static inline void acpi_disable_pci(void) { }
+static inline void disable_acpi(void) { }
+
+#endif	/* !CONFIG_ACPI */
 
 #define ARCH_HAS_POWER_INIT	1
 
diff --git a/include/asm-i386/suspend.h b/include/asm-i386/suspend.h
index 8dbaafe..a252073 100644
--- a/include/asm-i386/suspend.h
+++ b/include/asm-i386/suspend.h
@@ -21,7 +21,7 @@ struct saved_context {
 	unsigned long return_address;
 } __attribute__((packed));
 
-#ifdef CONFIG_ACPI_SLEEP
+#ifdef CONFIG_ACPI
 extern unsigned long saved_eip;
 extern unsigned long saved_esp;
 extern unsigned long saved_ebp;
diff --git a/include/asm-ia64/acpi.h b/include/asm-ia64/acpi.h
index 5b52635..49730ff 100644
--- a/include/asm-ia64/acpi.h
+++ b/include/asm-ia64/acpi.h
@@ -100,6 +100,11 @@ const char *acpi_get_sysname (void);
 int acpi_request_vector (u32 int_type);
 int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
+/* routines for saving/restoring kernel state */
+extern int acpi_save_state_mem(void);
+extern void acpi_restore_state_mem(void);
+extern unsigned long acpi_wakeup_address;
+
 /*
  * Record the cpei override flag and current logical cpu. This is
  * useful for CPU removal.
diff --git a/include/asm-x86_64/acpi.h b/include/asm-x86_64/acpi.h
index 1da8f49..9817335 100644
--- a/include/asm-x86_64/acpi.h
+++ b/include/asm-x86_64/acpi.h
@@ -108,6 +108,15 @@ static inline void acpi_disable_pci(void)
 }
 extern int acpi_irq_balance_set(char *str);
 
+/* routines for saving/restoring kernel state */
+extern int acpi_save_state_mem(void);
+extern void acpi_restore_state_mem(void);
+
+extern unsigned long acpi_wakeup_address;
+
+/* early initialization routine */
+extern void acpi_reserve_bootmem(void);
+
 #else	/* !CONFIG_ACPI */
 
 #define acpi_lapic 0
@@ -121,19 +130,6 @@ extern int acpi_numa;
 extern int acpi_scan_nodes(unsigned long start, unsigned long end);
 #define NR_NODE_MEMBLKS (MAX_NUMNODES*2)
 
-#ifdef CONFIG_ACPI_SLEEP
-
-/* routines for saving/restoring kernel state */
-extern int acpi_save_state_mem(void);
-extern void acpi_restore_state_mem(void);
-
-extern unsigned long acpi_wakeup_address;
-
-/* early initialization routine */
-extern void acpi_reserve_bootmem(void);
-
-#endif /*CONFIG_ACPI_SLEEP*/
-
 extern int acpi_disabled;
 extern int acpi_pci_disabled;
 
diff --git a/include/asm-x86_64/suspend.h b/include/asm-x86_64/suspend.h
index 9c3f8de..b897e8c 100644
--- a/include/asm-x86_64/suspend.h
+++ b/include/asm-x86_64/suspend.h
@@ -44,7 +44,6 @@ extern unsigned long saved_context_eflags;
 
 extern void fix_processor_context(void);
 
-#ifdef CONFIG_ACPI_SLEEP
 extern unsigned long saved_rip;
 extern unsigned long saved_rsp;
 extern unsigned long saved_rbp;
@@ -54,4 +53,3 @@ extern unsigned long saved_rdi;
 
 /* routines for saving/restoring kernel state */
 extern int acpi_save_state_mem(void);
-#endif
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ddebf3f..eb26f2b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -689,7 +689,7 @@ static ctl_table kern_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
-#ifdef CONFIG_ACPI_SLEEP
+#if defined(CONFIG_ACPI) && defined(CONFIG_X86)
 	{
 		.ctl_name	= KERN_ACPI_VIDEO_FLAGS,
 		.procname	= "acpi_video_flags",
-- 
1.5.3.rc2.22.g69a9b
-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--Boundary-00=_0wupGz3wYEW6fPF--
