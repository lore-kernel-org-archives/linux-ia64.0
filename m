From: Matt Domsch <Matt_Domsch@Dell.com>
Date: Fri, 13 Dec 2002 23:31:03 +0000
Subject: [Linux-ia64] [PATCH] efivars.c locking fixes
Message-Id: <marc-linux-ia64-105590709805563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

With thanks to Peter Chubb and his preempt work, here's a patch for
efivars.c that applies to both 2.4.x and 2.5.x to clean up the SMP
locking issues discovered there.  The efivar_lock was being held
across calls to create_proc_entry(), and worse, kmalloc().  I believe
this fixes those.

This has been tested on a Big Sur on 2.5.50 and seems to work
correctly.  This hasn't been tested on 2.4.20 (though it patches,
compiles and builds properly, and I expect it works fine), something
immediately after efivars_init() finishes crashes and I haven't been
able to track it down yet, though I'm pretty certain it's not
something in efivars.c.

Thanks,
Matt


-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--- linux-2.5-ia64/arch/ia64/kernel/efivars.c	Fri Dec 13 17:22:01 2002
+++ linux-2.5-ia64-test/arch/ia64/kernel/efivars.c	Fri Dec 13 10:33:51 2002
@@ -29,6 +29,9 @@
  *
  * Changelog:
  *
+ *  10 Dec 2002 - Matt Domsch <Matt_Domsch@dell.com>
+ *   fix locking per Peter Chubb's findings
+ * 
  *  25 Mar 2002 - Matt Domsch <Matt_Domsch@dell.com>
  *   move uuid_unparse() to include/asm-ia64/efi.h:efi_guid_unparse()
  *
@@ -73,7 +76,7 @@ MODULE_AUTHOR("Matt Domsch <Matt_Domsch@
 MODULE_DESCRIPTION("/proc interface to EFI Variables");
 MODULE_LICENSE("GPL");
 
-#define EFIVARS_VERSION "0.05 2002-Mar-26"
+#define EFIVARS_VERSION "0.06 2002-Dec-10"
 
 static int
 efivar_read(char *page, char **start, off_t off,
@@ -106,6 +109,14 @@ typedef struct _efivar_entry_t {
 	struct list_head        list;
 } efivar_entry_t;
 
+/*
+  efivars_lock protects two things:
+  1) efivar_list - adds, removals, reads, writes
+  2) efi.[gs]et_variable() calls.
+  It must not be held when creating proc entries or calling kmalloc.
+  efi.get_next_variable() is only called from efivars_init(),
+  which is protected by the BKL, so that path is safe.
+*/
 static spinlock_t efivars_lock = SPIN_LOCK_UNLOCKED;
 static LIST_HEAD(efivar_list);
 static struct proc_dir_entry *efi_vars_dir = NULL;
@@ -150,6 +161,7 @@ proc_calc_metrics(char *page, char **sta
  *    variable_name_size = number of bytes required to hold
  *                         variable_name (not counting the NULL
  *                         character at the end.
+ *    efivars_lock is not held on entry or exit.
  * Returns 1 on failure, 0 on success
  */
 static int
@@ -160,10 +172,12 @@ efivar_create_proc_entry(unsigned long v
 
 	int i, short_name_size = variable_name_size /
 		sizeof(efi_char16_t) + 38;
-	char *short_name = kmalloc(short_name_size+1,
-				   GFP_KERNEL);
-	efivar_entry_t *new_efivar = kmalloc(sizeof(efivar_entry_t),
-					     GFP_KERNEL);
+	char *short_name;
+	efivar_entry_t *new_efivar;
+
+        short_name = kmalloc(short_name_size+1, GFP_KERNEL);
+        new_efivar = kmalloc(sizeof(efivar_entry_t), GFP_KERNEL);
+
 	if (!short_name || !new_efivar)  {
 		if (short_name)        kfree(short_name);
 		if (new_efivar)        kfree(new_efivar);
@@ -188,19 +202,18 @@ efivar_create_proc_entry(unsigned long v
 	*(short_name + strlen(short_name)) = '-';
 	efi_guid_unparse(vendor_guid, short_name + strlen(short_name));
 
-
 	/* Create the entry in proc */
 	new_efivar->entry = create_proc_entry(short_name, 0600, efi_vars_dir);
 	kfree(short_name); short_name = NULL;
 	if (!new_efivar->entry) return 1;
 
-
 	new_efivar->entry->data = new_efivar;
 	new_efivar->entry->read_proc = efivar_read;
 	new_efivar->entry->write_proc = efivar_write;
 
+        spin_lock(&efivars_lock);
 	list_add(&new_efivar->list, &efivar_list);
-
+        spin_unlock(&efivars_lock);
 
 	return 0;
 }
@@ -326,6 +339,8 @@ efivar_write(struct file *file, const ch
 		kfree(efivar);
 	}
 
+	spin_unlock(&efivars_lock);
+
 	/* If this is a new variable, set up the proc entry for it. */
 	if (!found) {
 		efivar_create_proc_entry(utf8_strsize(var_data->VariableName,
@@ -336,7 +351,6 @@ efivar_write(struct file *file, const ch
 
 	kfree(var_data);
 	MOD_DEC_USE_COUNT;
-	spin_unlock(&efivars_lock);
 	return size;
 }
 
@@ -351,8 +365,6 @@ efivars_init(void)
 	efi_char16_t *variable_name = kmalloc(1024, GFP_KERNEL);
 	unsigned long variable_name_size = 1024;
 
-	spin_lock(&efivars_lock);
-
 	printk(KERN_INFO "EFI Variables Facility v%s\n", EFIVARS_VERSION);
 
         /* Since efi.c happens before procfs is available,
@@ -365,8 +377,6 @@ efivars_init(void)
 
 	efi_vars_dir = proc_mkdir("vars", efi_dir);
 
-
-
 	/* Per EFI spec, the maximum storage allocated for both
 	   the variable name and variable data is 1024 bytes.
 	*/
@@ -398,7 +408,6 @@ efivars_init(void)
 	} while (status != EFI_NOT_FOUND);
 
 	kfree(variable_name);
-	spin_unlock(&efivars_lock);
 	return 0;
 }
 
@@ -408,17 +417,16 @@ efivars_exit(void)
 	struct list_head *pos, *n;
 	efivar_entry_t *efivar;
 
-	spin_lock(&efivars_lock);
-
+        spin_lock(&efivars_lock);
 	list_for_each_safe(pos, n, &efivar_list) {
 		efivar = efivar_entry(pos);
 		remove_proc_entry(efivar->entry->name, efi_vars_dir);
 		list_del(&efivar->list);
 		kfree(efivar);
 	}
-	remove_proc_entry(efi_vars_dir->name, efi_dir);
 	spin_unlock(&efivars_lock);
 
+	remove_proc_entry(efi_vars_dir->name, efi_dir);
 }
 
 module_init(efivars_init);


