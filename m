From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 13 Aug 2003 22:11:44 +0000
Subject: [PATCH] Trivial 2.5 efivars.c whitespace cleanup
Message-Id: <marc-linux-ia64-106081285931321@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Against linux-2.5.  Convert leading spaces to tabs.

=== arch/ia64/kernel/efivars.c 1.12 vs edited ==--- 1.12/arch/ia64/kernel/efivars.c	Mon Jun 23 01:09:40 2003
+++ edited/arch/ia64/kernel/efivars.c	Wed Aug 13 17:12:55 2003
@@ -168,13 +168,12 @@
 			 efi_char16_t *variable_name,
 			 efi_guid_t *vendor_guid)
 {
-
 	int i, short_name_size = variable_name_size / sizeof(efi_char16_t) + 38;
 	char *short_name;
 	efivar_entry_t *new_efivar;
 
-        short_name = kmalloc(short_name_size+1, GFP_KERNEL);
-        new_efivar = kmalloc(sizeof(efivar_entry_t), GFP_KERNEL);
+	short_name = kmalloc(short_name_size+1, GFP_KERNEL);
+	new_efivar = kmalloc(sizeof(efivar_entry_t), GFP_KERNEL);
 
 	if (!short_name || !new_efivar)  {
 		if (short_name)        kfree(short_name);
@@ -210,9 +209,9 @@
 	new_efivar->entry->read_proc = efivar_read;
 	new_efivar->entry->write_proc = efivar_write;
 
-        spin_lock(&efivars_lock);
-        list_add(&new_efivar->list, &efivar_list);
-        spin_unlock(&efivars_lock);
+	spin_lock(&efivars_lock);
+	list_add(&new_efivar->list, &efivar_list);
+	spin_unlock(&efivars_lock);
 
 	return 0;
 }
@@ -283,7 +282,7 @@
 	if (!var_data)
 		return -ENOMEM;
 	if (copy_from_user(var_data, buffer, size)) {
-                kfree(var_data);
+		kfree(var_data);
 		return -EFAULT;
 	}
 
@@ -349,7 +348,6 @@
 static int __init
 efivars_init(void)
 {
-
 	efi_status_t status;
 	efi_guid_t vendor_guid;
 	efi_char16_t *variable_name = kmalloc(1024, GFP_KERNEL);
@@ -357,13 +355,13 @@
 
 	printk(KERN_INFO "EFI Variables Facility v%s\n", EFIVARS_VERSION);
 
-        /* Since efi.c happens before procfs is available,
-           we create the directory here if it doesn't
-           already exist.  There's probably a better way
-           to do this.
-        */
-        if (!efi_dir)
-                efi_dir = proc_mkdir("efi", NULL);
+	/* Since efi.c happens before procfs is available,
+	   we create the directory here if it doesn't
+	   already exist.  There's probably a better way
+	   to do this.
+	*/
+	if (!efi_dir)
+		efi_dir = proc_mkdir("efi", NULL);
 
 	efi_vars_dir = proc_mkdir("vars", efi_dir);
 
@@ -407,7 +405,7 @@
 	struct list_head *pos, *n;
 	efivar_entry_t *efivar;
 
-        spin_lock(&efivars_lock);
+	spin_lock(&efivars_lock);
 	list_for_each_safe(pos, n, &efivar_list) {
 		efivar = efivar_entry(pos);
 		remove_proc_entry(efivar->entry->name, efi_vars_dir);

