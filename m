From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 13 Aug 2003 22:22:01 +0000
Subject: [PATCH] 2.5 export EFI systab
Message-Id: <marc-linux-ia64-106081372832133@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I know this probably needs to get exported somewhere other than
/proc, but the rest of efivars is still in /proc and if somebody does
convert efivars, they might as well do this systab bit at the same
time.

This is from 2.4 and is originally due to Chad Smith <chad_smith@hp.com>

--- linux-2.5/arch/ia64/kernel/efivars.c.orig	2003-08-13 17:18:36.000000000 -0600
+++ linux-2.5/arch/ia64/kernel/efivars.c	2003-08-13 17:20:07.000000000 -0600
@@ -343,7 +343,69 @@
 	return size;
 }
 
+/*
+ * The EFI system table contains pointers to the SAL system table,
+ * HCDP, ACPI, SMBIOS, etc, that may be useful to applications.
+ */
+static ssize_t
+efi_systab_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+{
+	void *data;
+	u8 *proc_buffer;
+	ssize_t size, length;
+	int ret;
+	const int max_nr_entries = 7; 	/* num ptrs to tables we could expose */
+	const int max_line_len = 80;
+
+	if (!efi.systab)
+		return 0;
+
+	proc_buffer = kmalloc(max_nr_entries * max_line_len, GFP_KERNEL);
+	if (!proc_buffer)
+		return -ENOMEM;
+
+	length = 0;
+	if (efi.mps)
+		length += sprintf(proc_buffer + length, "MPS=0x%lx\n", __pa(efi.mps));
+	if (efi.acpi20)
+		length += sprintf(proc_buffer + length, "ACPI20=0x%lx\n", __pa(efi.acpi20));
+	if (efi.acpi)
+		length += sprintf(proc_buffer + length, "ACPI=0x%lx\n", __pa(efi.acpi));
+	if (efi.smbios)
+		length += sprintf(proc_buffer + length, "SMBIOS=0x%lx\n", __pa(efi.smbios));
+	if (efi.sal_systab)
+		length += sprintf(proc_buffer + length, "SAL=0x%lx\n", __pa(efi.sal_systab));
+	if (efi.hcdp)
+		length += sprintf(proc_buffer + length, "HCDP=0x%lx\n", __pa(efi.hcdp));
+	if (efi.boot_info)
+		length += sprintf(proc_buffer + length, "BOOTINFO=0x%lx\n", __pa(efi.boot_info));
+
+	if (*ppos >= length) {
+		ret = 0;
+		goto out;
+	}
+
+	data = proc_buffer + file->f_pos;
+	size = length - file->f_pos;
+	if (size > count)
+		size = count;
+	if (copy_to_user(buffer, data, size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	*ppos += size;
+	ret = size;
 
+out:
+	kfree(proc_buffer);
+	return ret;
+}
+
+static struct proc_dir_entry *efi_systab_entry;
+static struct file_operations efi_systab_fops = {
+	.read = efi_systab_read,
+};
 
 static int __init
 efivars_init(void)
@@ -363,6 +425,10 @@
 	if (!efi_dir)
 		efi_dir = proc_mkdir("efi", NULL);
 
+	efi_systab_entry = create_proc_entry("systab", S_IRUSR | S_IRGRP, efi_dir);
+	if (efi_systab_entry)
+		efi_systab_entry->proc_fops = &efi_systab_fops;
+
 	efi_vars_dir = proc_mkdir("vars", efi_dir);
 
 	/* Per EFI spec, the maximum storage allocated for both
@@ -406,6 +472,8 @@
 	efivar_entry_t *efivar;
 
 	spin_lock(&efivars_lock);
+	if (efi_systab_entry)
+		remove_proc_entry(efi_systab_entry->name, efi_dir);
 	list_for_each_safe(pos, n, &efivar_list) {
 		efivar = efivar_entry(pos);
 		remove_proc_entry(efivar->entry->name, efi_vars_dir);

