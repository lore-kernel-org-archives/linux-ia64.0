From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Fri, 20 Apr 2001 17:02:46 +0000
Subject: [Linux-ia64] [PATCH] /proc/efi moves to /proc/efi/vars
Message-Id: <marc-linux-ia64-105590693005440@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below please find a patch, against 2.4.3 + ia64-010405 which moves the
EFI variables from /proc/efi to /proc/efi/vars.  This allows other
modules to create files in /proc/efi and not clash with the
variables.  Also, CONFIG_IA64_EFIVARS has changed to CONFIG_EFI_VARS,
consistent with CONFIG_EFI_PARTITION.
I've tested this against 2.4.3 and it works.  David, please include
this in your next IA-64 patch.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux



diff -burN linux/Documentation/Configure.help linux.efivars/Documentation/Configure.help
--- linux/Documentation/Configure.help	Fri Apr 20 11:49:06 2001
+++ linux.efivars/Documentation/Configure.help	Thu Apr 19 16:33:38 2001
@@ -17342,12 +17342,11 @@
   To use this option, you have to check that the "/proc file system
   support" (CONFIG_PROC_FS) is enabled, too.

-/proc/efi support
-CONFIG_IA64_EFIVARS
+/proc/efi/vars support
+CONFIG_EFI_VARS
   If you say Y here, you are able to get EFI (Extensible Firmware
-  Interface) variable information in /proc/pal.  This can be used to
-  change the boot order in the EFI Boot Manager.
-
+  Interface) variable information in /proc/efi/vars.  You may read,
+  write, create, and destroy EFI variables through this interface.

   To use this option, you have to check that the "/proc file system
   support" (CONFIG_PROC_FS) is enabled, too.
diff -burN linux/arch/ia64/config.in linux.efivars/arch/ia64/config.in
--- linux/arch/ia64/config.in	Fri Apr 20 11:49:06 2001
+++ linux.efivars/arch/ia64/config.in	Thu Apr 19 16:33:38 2001
@@ -110,7 +110,7 @@
 bool 'SMP support' CONFIG_SMP
 bool 'Performance monitor support' CONFIG_PERFMON
 tristate '/proc/pal support' CONFIG_IA64_PALINFO
-tristate '/proc/efi support' CONFIG_IA64_EFIVARS
+tristate '/proc/efi/vars support' CONFIG_EFI_VARS

 bool 'Networking support' CONFIG_NET
 bool 'System V IPC' CONFIG_SYSVIPC
diff -burN linux/arch/ia64/kernel/Makefile linux.efivars/arch/ia64/kernel/Makefile
--- linux/arch/ia64/kernel/Makefile	Fri Apr 20 11:49:06 2001
+++ linux.efivars/arch/ia64/kernel/Makefile	Thu Apr 19 16:33:38 2001
@@ -19,7 +19,7 @@
 obj-$(CONFIG_IA64_GENERIC) += machvec.o iosapic.o
 obj-$(CONFIG_IA64_DIG) += iosapic.o
 obj-$(CONFIG_IA64_PALINFO) += palinfo.o
-obj-$(CONFIG_IA64_EFIVARS) += efivars.o
+obj-$(CONFIG_EFI_VARS) += efivars.o
 obj-$(CONFIG_PCI) += pci.o
 obj-$(CONFIG_SMP) += smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) += mca.o mca_asm.o
diff -burN linux/arch/ia64/kernel/efi.c linux.efivars/arch/ia64/kernel/efi.c
--- linux/arch/ia64/kernel/efi.c	Fri Apr 20 11:49:06 2001
+++ linux.efivars/arch/ia64/kernel/efi.c	Fri Apr 20 11:35:07 2001
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/time.h>
+#include <linux/proc_fs.h>

 #include <asm/efi.h>
 #include <asm/io.h>
@@ -37,6 +38,17 @@
 struct efi efi;
 static efi_runtime_services_t *runtime;

+/*
+ * efi_dir is allocated here, but the directory isn't created
+ * here, as proc_mkdir() doesn't work this early in the bootup
+ * process.  Therefore, each module, like efivars, must test for
+ *    if (!efi_dir)  efi_dir = proc_mkdir("efi", NULL);
+ * prior to creating their own entries under /proc/efi.
+ */
+#ifdef CONFIG_PROC_FS
+struct proc_dir_entry *efi_dir = NULL;
+#endif
+
 static unsigned long mem_limit = ~0UL;

 static efi_status_t
@@ -441,4 +454,10 @@
 	efi.set_variable = __va(runtime->set_variable);
 	efi.get_next_high_mono_count = __va(runtime->get_next_high_mono_count);
 	efi.reset_system = __va(runtime->reset_system);
+}
+
+static void __exit
+efivars_exit(void)
+{
+ 	remove_proc_entry(efi_dir->name, NULL);
 }
diff -burN linux/arch/ia64/kernel/efivars.c linux.efivars/arch/ia64/kernel/efivars.c
--- linux/arch/ia64/kernel/efivars.c	Fri Apr 20 11:49:06 2001
+++ linux.efivars/arch/ia64/kernel/efivars.c	Fri Apr 20 11:33:58 2001
@@ -6,8 +6,8 @@
  * This code takes all variables accessible from EFI runtime and
  *  exports them via /proc
  *
- * Reads to /proc/efi/varname return an efi_variable_t structure.
- * Writes to /proc/efi/varname must be an efi_variable_t structure.
+ * Reads to /proc/efi/vars/varname return an efi_variable_t structure.
+ * Writes to /proc/efi/vars/varname must be an efi_variable_t structure.
  * Writes with DataSize = 0 or Attributes = 0 deletes the variable.
  * Writes with a new value in VariableName+VendorGuid creates
  * a new variable.
@@ -29,6 +29,15 @@
  *
  * Changelog:
  *
+ *  20 April 2001 - Matt Domsch <Matt_Domsch@dell.com>
+ *   Moved vars from /proc/efi to /proc/efi/vars, and made
+ *   efi.c own the /proc/efi directory.
+ *   v0.03 release to linux-ia64@linuxia64.org
+ *
+ *  26 March 2001 - Matt Domsch <Matt_Domsch@dell.com>
+ *   At the request of Stephane, moved ownership of /proc/efi
+ *   to efi.c, and now efivars lives under /proc/efi/vars.
+ *
  *  12 March 2001 - Matt Domsch <Matt_Domsch@dell.com>
  *   Feedback received from Stephane Eranian incorporated.
  *   efivar_write() checks copy_from_user() return value.
@@ -57,7 +66,7 @@
 MODULE_AUTHOR("Matt Domsch <Matt_Domsch@Dell.com>");
 MODULE_DESCRIPTION("/proc interface to EFI Variables");

-#define EFIVARS_VERSION "0.02 2001-Mar-12"
+#define EFIVARS_VERSION "0.03 2001-Apr-20"

 static int
 efivar_read(char *page, char **start, off_t off,
@@ -92,7 +101,7 @@

 spinlock_t efivars_lock = SPIN_LOCK_UNLOCKED;
 static LIST_HEAD(efivar_list);
-static struct proc_dir_entry *efi_dir = NULL;
+static struct proc_dir_entry *efi_vars_dir = NULL;

 #define efivar_entry(n) list_entry(n, efivar_entry_t, list)

@@ -188,7 +197,7 @@


 	/* Create the entry in proc */
-	new_efivar->entry = create_proc_entry(short_name, 0600, efi_dir);
+	new_efivar->entry = create_proc_entry(short_name, 0600, efi_vars_dir);
 	kfree(short_name); short_name = NULL;
 	if (!new_efivar->entry) return 1;

@@ -286,7 +295,7 @@
 	/* Since the data ptr we've currently got is probably for
 	   a different variable find the right variable.
 	   This allows any properly formatted data structure to
-	   be written to any of the files in /proc/efi and it will work.
+	   be written to any of the files in /proc/efi/vars and it will work.
 	*/
 	list_for_each(pos, &efivar_list) {
 		search_efivar = efivar_entry(pos);
@@ -320,7 +329,7 @@

 	if (!var_data->DataSize || !var_data->Attributes) {
 		/* We just deleted the NVRAM variable */
-		remove_proc_entry(efivar->entry->name, efi_dir);
+		remove_proc_entry(efivar->entry->name, efi_vars_dir);
 		list_del(&efivar->list);
 		kfree(efivar);
 	}
@@ -354,12 +364,22 @@

 	printk(KERN_INFO "EFI Variables Facility v%s\n", EFIVARS_VERSION);

+        /* Since efi.c happens before procfs is available,
+           we create the directory here if it doesn't
+           already exist.  There's probably a better way
+           to do this.
+        */
+        if (!efi_dir)
+                efi_dir = proc_mkdir("efi", NULL);
+
+	efi_vars_dir = proc_mkdir("vars", efi_dir);
+
+
+
 	/* Per EFI spec, the maximum storage allocated for both
 	   the variable name and variable data is 1024 bytes.
 	*/

-	efi_dir = proc_mkdir("efi", NULL);
-
 	memset(variable_name, 0, 1024);

 	do {
@@ -401,11 +421,11 @@

 	list_for_each(pos, &efivar_list) {
 		efivar = efivar_entry(pos);
-		remove_proc_entry(efivar->entry->name, efi_dir);
+		remove_proc_entry(efivar->entry->name, efi_vars_dir);
 		list_del(&efivar->list);
 		kfree(efivar);
 	}
-	remove_proc_entry(efi_dir->name, NULL);
+	remove_proc_entry(efi_vars_dir->name, efi_dir);
 	spin_unlock(&efivars_lock);

 }
diff -burN linux/arch/ia64/kernel/ia64_ksyms.c linux.efivars/arch/ia64/kernel/ia64_ksyms.c
--- linux/arch/ia64/kernel/ia64_ksyms.c	Fri Apr 20 11:49:06 2001
+++ linux.efivars/arch/ia64/kernel/ia64_ksyms.c	Thu Apr 19 16:33:38 2001
@@ -137,3 +137,8 @@

 extern struct efi efi;
 EXPORT_SYMBOL(efi);
+
+#include <linux/proc_fs.h>
+extern struct proc_dir_entry *efi_dir;
+EXPORT_SYMBOL(efi_dir);
+
diff -burN linux/include/asm-ia64/efi.h linux.efivars/include/asm-ia64/efi.h
--- linux/include/asm-ia64/efi.h	Fri Apr 20 11:49:07 2001
+++ linux.efivars/include/asm-ia64/efi.h	Fri Apr 20 11:32:23 2001
@@ -15,6 +15,7 @@
 #include <linux/string.h>
 #include <linux/time.h>
 #include <linux/types.h>
+#include <linux/proc_fs.h>

 #include <asm/page.h>
 #include <asm/system.h>
@@ -245,5 +246,13 @@
 #define EFI_VARIABLE_NON_VOLATILE       0x0000000000000001
 #define EFI_VARIABLE_BOOTSERVICE_ACCESS 0x0000000000000002
 #define EFI_VARIABLE_RUNTIME_ACCESS     0x0000000000000004
+
+
+/*
+ * efi_dir is allocated in arch/ia64/kernel/efi.c.
+ */
+#ifdef CONFIG_PROC_FS
+extern struct proc_dir_entry *efi_dir;
+#endif

 #endif /* _ASM_IA64_EFI_H */



