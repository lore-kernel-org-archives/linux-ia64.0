From: Matt Domsch <Matt_Domsch@dell.com>
Date: Tue, 08 Mar 2005 23:15:34 +0000
Subject: Re: efibootmgr 0.5.1 (was: efibootmgr fixes for EFI 1.10)
Message-Id: <20050308231534.GB27091@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050308231433.GA27091@lists.us.dell.com>
In-Reply-To: <20050308231433.GA27091@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 08, 2005 at 05:14:33PM -0600, Matt Domsch wrote:
> Thanks Alex.  I applied your patch, with a couple minor changes (more
> verbose warning messages and how to eliminate them).
> 
> I've released efibootmgr 0.5.1 with these changes.
> http://linux.dell.com/files/efibootmgr/efibootmgr-0.5.1.tar.gz
> http://linux.dell.com/files/efibootmgr/efibootmgr-0.5.1.tar.gz.sign
> 
> I'll send the actual patch between 0.5.0 and 0.5.1 in a following
> message.

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

diff -urNp --exclude-from=/home/mdomsch/excludes --minimal efibootmgr-0.5.0/AUTHORS efibootmgr-0.5.1/AUTHORS
--- efibootmgr-0.5.0/AUTHORS	Tue Mar  8 16:59:13 2005
+++ efibootmgr-0.5.1/AUTHORS	Tue Mar  8 16:37:08 2005
@@ -16,3 +16,7 @@ dann frazier <dannf@debian.org>
 Joshua Giles <Joshua_Giles@dell.com>
 - walk the PCI path inserting parent bridge device path components for
   network boot and EDD30 entries.
+
+Alex Williamson <alex.williamson@hp.com>
+- Patch to efi.c and efibootmgr.c for handling BootXXXX values
+  using uppercase hex rather than lowercase, per EFI 1.10 spec.
diff -urNp --exclude-from=/home/mdomsch/excludes --minimal efibootmgr-0.5.0/Makefile efibootmgr-0.5.1/Makefile
--- efibootmgr-0.5.0/Makefile	Tue Mar  8 16:59:13 2005
+++ efibootmgr-0.5.1/Makefile	Tue Mar  8 16:38:27 2005
@@ -1,9 +1,9 @@
   default: all
 
-  RELEASE_DATE := "26-Aug-2004"
+  RELEASE_DATE := "08-Mar-2005"
   RELEASE_MAJOR := 0
   RELEASE_MINOR := 5
-  RELEASE_SUBLEVEL := 0
+  RELEASE_SUBLEVEL := 1
   RELEASE_EXTRALEVEL :   RELEASE_NAME := efibootmgr
   RELEASE_STRING := $(RELEASE_NAME)-$(RELEASE_MAJOR).$(RELEASE_MINOR).$(RELEASE_SUBLEVEL)$(RELEASE_EXTRALEVEL)
diff -urNp --exclude-from=/home/mdomsch/excludes --minimal efibootmgr-0.5.0/doc/ChangeLog efibootmgr-0.5.1/doc/ChangeLog
--- efibootmgr-0.5.0/doc/ChangeLog	Tue Mar  8 16:59:13 2005
+++ efibootmgr-0.5.1/doc/ChangeLog	Tue Mar  8 16:49:24 2005
@@ -1,3 +1,10 @@
+* Tue Mar 08 2005 Matt Domsch <Matt_Domsch@dell.com>
+- applied patch from Alex Williamson for handling BootXXXX values
+  using uppercase hex rather than lowercase, per EFI 1.10 spec.
+- this also allows the full 65k boot entries, rather than requiring all
+  entries to begin with a zero.
+- v0.5.1 released
+
 * Thu Aug 26 2004 Matt Domsch <Matt_Domsch@dell.com>
 - v0.5.0-test4 released as v0.5.0 with no code changes
 
Binary files efibootmgr-0.5.0/efibootmgr-0.5.1.tar.gz and efibootmgr-0.5.1/efibootmgr-0.5.1.tar.gz differ
diff -urNp --exclude-from=/home/mdomsch/excludes --minimal efibootmgr-0.5.0/efibootmgr-0.5.1.tar.gz.sign efibootmgr-0.5.1/efibootmgr-0.5.1.tar.gz.sign
diff -urNp --exclude-from=/home/mdomsch/excludes --minimal efibootmgr-0.5.0/efibootmgr.spec efibootmgr-0.5.1/efibootmgr.spec
--- efibootmgr-0.5.0/efibootmgr.spec	Tue Mar  8 16:59:13 2005
+++ efibootmgr-0.5.1/efibootmgr.spec	Thu Aug 26 16:01:53 2004
@@ -1,14 +1,15 @@
 Summary: EFI Boot Manager
 Name: efibootmgr
-Version: 0.4.1
+Version: 0.5.0
 Release: 0
 Group: System Environment/Base
 Copyright: GPL
-Vendor: Dell Computer Corporation www.dell.com
+Vendor: Dell linux.dell.com
 Packager: Matt Domsch <Matt_Domsch@dell.com>
 
 
-Source0: http://domsch.com/linux/ia64/efibootmgr-0.5.1/efibootmgr-%{version}.tar.gz
+Source0: http://linux.dell.com/efibootmgr-0.5.1/permalink/efibootmgr-%{version}.tar.gz
+Source1: http://linux.dell.com/efibootmgr-0.5.1/permalink/efibootmgr-%{version}.tar.gz.sign
 
 %description
 efibootmgr displays and allows the user to edit the Intel Extensible
@@ -32,5 +33,8 @@ install --group=root --owner=root --mode
 
     
 %changelog
+* Thu Aug 24 2004 Matt Domsch <Matt_Domsch@dell.com>
+- new home linux.dell.com
+
 * Fri May 18 2001 Matt Domsch <Matt_Domsch@dell.com>
 - See doc/ChangeLog
diff -urNp --exclude-from=/home/mdomsch/excludes --minimal efibootmgr-0.5.0/src/efibootmgr-0.5.1/efibootmgr.c efibootmgr-0.5.1/src/efibootmgr-0.5.1/efibootmgr.c
--- efibootmgr-0.5.0/src/efibootmgr/efibootmgr.c	Tue Mar  8 16:59:13 2005
+++ efibootmgr-0.5.1/src/efibootmgr/efibootmgr.c	Tue Mar  8 16:47:19 2005
@@ -32,6 +32,7 @@
 
 #define _GNU_SOURCE
 
+#include <ctype.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -215,8 +216,8 @@ warn_duplicate_name(list_t *boot_list)
 			boot->var_data.Data;
 		if (!efichar_char_strcmp(opts.label,
 					 load_option->description)) {
-			fprintf(stderr, "** Warning ** : Boot%04x has same label %s\n",
-			       boot->num,
+			fprintf(stderr, "** Warning ** : %.8s has same label %s\n",
+			       boot->name->d_name,
 			       opts.label);
 		}
 	}
@@ -228,9 +229,21 @@ make_boot_var(list_t *boot_list)
 {
 	var_entry_t *boot;
 	int free_number;
+	list_t *pos;
 
-	if (opts.bootnum = -1) free_number = find_free_boot_var(boot_list);
-	else                    free_number = opts.bootnum;
+	if (opts.bootnum = -1)
+		free_number = find_free_boot_var(boot_list);
+	else {
+		list_for_each(pos, boot_list) {
+			boot = list_entry(pos, var_entry_t, list);
+			if (boot->num = opts.bootnum) {
+				fprintf(stderr, "** Warning ** : bootnum %04X "
+				        "already exists\n", opts.bootnum);
+				return NULL;
+			}
+		}
+		free_number = opts.bootnum;
+	}
 
 	if (free_number = -1) return NULL;
 
@@ -398,13 +411,20 @@ delete_boot_var(uint16_t num)
 	list_t *pos, *n;
 	var_entry_t *boot;
 
-	snprintf(name, sizeof(name), "Boot%04x", num);
+	snprintf(name, sizeof(name), "Boot%04X", num);
 	memset(&var, 0, sizeof(var));
 	fill_var(&var, name);
 	status = delete_variable(&var);
 
-	if (status) return status;
+	/* For backwards compatibility, try to delete abcdef entries as well */
+	if (status) {
+		snprintf(name, sizeof(name), "Boot%04x", num);
+		memset(&var, 0, sizeof(var));
+		fill_var(&var, name);
+		status = delete_variable(&var);
+	}
 
+	if (status) return status;
 	list_for_each_safe(pos, n, &boot_entry_list) {
 		boot = list_entry(pos, var_entry_t, list);
 		if (boot->num = num) {
@@ -424,11 +444,27 @@ set_var_nums(const char *pattern, list_t
 	list_t *pos;
 	var_entry_t *var;
 	int num=0, rc;
+	char *name;
+	int warn=0;
 
 	list_for_each(pos, list) {
 		var = list_entry(pos, var_entry_t, list);
 		rc = sscanf(var->name->d_name, pattern, &num);
-		if (rc = 1) var->num = num;
+		if (rc = 1) {
+			var->num = num;
+			name = var->name->d_name; /* shorter name */
+			if ((isalpha(name[4]) && islower(name[4])) ||
+			    (isalpha(name[5]) && islower(name[5])) ||
+			    (isalpha(name[6]) && islower(name[6])) ||
+			    (isalpha(name[7]) && islower(name[7]))) {
+				fprintf(stderr, "** Warning ** : %.8s is not "
+				        "EFI 1.10 compliant (lowercase hex in name)\n", name);
+				warn++;
+			}
+		}
+	}
+	if (warn) {
+		fprintf(stderr, "** Warning ** : please recreate these using efibootmgr to remove this warning.\n");
 	}
 }
 
@@ -528,7 +564,7 @@ unparse_boot_order(uint16_t *order, int 
 	int i;
 	printf("BootOrder: ");
 	for (i=0; i<length; i++) {
-		printf("%04x", order[i]);
+		printf("%04X", order[i]);
 		if (i < (length-1))
 			printf(",");
 	}
@@ -586,7 +622,11 @@ show_boot_vars()
 				load_option->description, sizeof(description));
 		memset(text_path, 0, sizeof(text_path));
 		path = load_option_path(load_option);
-		printf("Boot%04x", boot->num);
+		if (boot->name)
+			printf("%.8s", boot->name->d_name);
+		else
+			printf("Boot%04X", boot->num);
+
 		if (load_option->attributes & LOAD_OPTION_ACTIVE)
 			printf("* ");
 		else    printf("  ");
@@ -790,7 +830,7 @@ parse_opts(int argc, char **argv)
 			opts.delete_boot = 1;
 			break;
 		case 'b':
-			rc = sscanf(optarg, "%x", &num);
+			rc = sscanf(optarg, "%X", &num);
 			if (rc = 1) opts.bootnum = num;
 			break;
 		case 'c':
@@ -920,7 +960,7 @@ main(int argc, char **argv)
 	if (!opts.testfile) {
 		num_boot_names = read_boot_var_names(&boot_names);
 		read_vars(boot_names, num_boot_names, &boot_entry_list);
-		set_var_nums("Boot%04x-%*s", &boot_entry_list);
+		set_var_nums("Boot%04X-%*s", &boot_entry_list);
 
 		if (opts.delete_boot) {
 			if (opts.bootnum = -1)
@@ -972,11 +1012,11 @@ main(int argc, char **argv)
 		if (!opts.quiet) {
 			num = read_boot_u16("BootNext");
 			if (num != -1 ) {
-				printf("BootNext: %04x\n", num);
+				printf("BootNext: %04X\n", num);
 			}
 			num = read_boot_u16("BootCurrent");
 			if (num != -1) {
-				printf("BootCurrent: %04x\n", num);
+				printf("BootCurrent: %04X\n", num);
 			}
 			num = read_boot_u16("Timeout");
 			if (num != -1) {
diff -urNp --exclude-from=/home/mdomsch/excludes --minimal efibootmgr-0.5.0/src/lib/efi.c efibootmgr-0.5.1/src/lib/efi.c
--- efibootmgr-0.5.0/src/lib/efi.c	Tue Mar  8 16:59:13 2005
+++ efibootmgr-0.5.1/src/lib/efi.c	Tue Mar  8 16:35:29 2005
@@ -20,6 +20,7 @@
 
 #define _FILE_OFFSET_BITS 64
 
+#include <ctype.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -171,9 +172,12 @@ create_or_edit_variable(efi_variable_t *
 static int
 select_boot_var_names(const struct dirent *d)
 {
-	int num, rc;
-	rc = sscanf(d->d_name, "Boot0%03x-%*s", &num);
-	return rc;
+	if (!strncmp(d->d_name, "Boot", 4) &&
+	    isxdigit(d->d_name[4]) && isxdigit(d->d_name[5]) &&
+	    isxdigit(d->d_name[6]) && isxdigit(d->d_name[7]) &&
+	    d->d_name[8] = '-')
+		return 1;
+	return 0;
 }
 
 int
@@ -716,7 +720,7 @@ make_linux_efi_variable(efi_variable_t *
 	memset(buffer,    0, sizeof(buffer));
 
 	/* VariableName needs to be BootXXXX */
-	sprintf(buffer, "Boot%04x", free_number);
+	sprintf(buffer, "Boot%04X", free_number);
 
 	efichar_from_char(var->VariableName, buffer, 1024);
 
