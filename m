From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 01 Mar 2005 23:22:51 +0000
Subject: efibootmgr fixes for EFI 1.10
Message-Id: <1109719371.12409.81.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   An EFI firmware engineer brought to my attention that efibootmgr is
not strictly compliant with a clarification that was added to the 1.10
EFI spec.  Section 3.1, page 3-2 now states the BootXXXX entries should
use upper case A-F.  Currently we use lowercase.  The patch below fixes
this problem and tries to be somewhat backwards compatible.  I kind of
doubt many people have more than 10 boot menu entries anyway.  While
poking around, I also added a warning to prevent creating boot entries
with the same number and removed the previous limitation of ignoring
entries greater than 0FFF.

   Please give this a try and let me know if there are any problems.
Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

--- efibootmgr-0.5.0/src/lib/efi.c	2005-02-28 16:00:18.782889342 -0700
+++ efibootmgr-0.5.0/src/lib/efi.c	2005-03-01 13:45:11.947945876 -0700
@@ -20,6 +20,7 @@
 
 #define _FILE_OFFSET_BITS 64
 
+#include <ctype.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -171,9 +172,12 @@
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
@@ -716,7 +720,7 @@
 	memset(buffer,    0, sizeof(buffer));
 
 	/* VariableName needs to be BootXXXX */
-	sprintf(buffer, "Boot%04x", free_number);
+	sprintf(buffer, "Boot%04X", free_number);
 
 	efichar_from_char(var->VariableName, buffer, 1024);
 
--- efibootmgr-0.5.0/src/efibootmgr/efibootmgr.c	2005-02-28 16:00:18.802420592 -0700
+++ efibootmgr-0.5.0/src/efibootmgr/efibootmgr.c	2005-03-01 13:32:05.899127380 -0700
@@ -32,6 +32,7 @@
 
 #define _GNU_SOURCE
 
+#include <ctype.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -208,6 +209,7 @@
 	list_t *pos;
 	var_entry_t *boot;
 	EFI_LOAD_OPTION *load_option;
+	char name[9];
 
 	list_for_each(pos, boot_list) {
 		boot = list_entry(pos, var_entry_t, list);
@@ -215,8 +217,9 @@
 			boot->var_data.Data;
 		if (!efichar_char_strcmp(opts.label,
 					 load_option->description)) {
-			fprintf(stderr, "** Warning ** : Boot%04x has same label %s\n",
-			       boot->num,
+			snprintf(name, 9, "%s", boot->name->d_name);
+			fprintf(stderr, "** Warning ** : %s has same label %s\n",
+			       name,
 			       opts.label);
 		}
 	}
@@ -228,9 +231,21 @@
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
 
@@ -398,13 +413,20 @@
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
@@ -424,11 +446,21 @@
 	list_t *pos;
 	var_entry_t *var;
 	int num=0, rc;
+	char name[9];
 
 	list_for_each(pos, list) {
 		var = list_entry(pos, var_entry_t, list);
 		rc = sscanf(var->name->d_name, pattern, &num);
-		if (rc = 1) var->num = num;
+		if (rc = 1) {
+			var->num = num;
+			snprintf(name, 9, "%s", var->name->d_name);
+			if ((isalpha(name[4]) && islower(name[4])) ||
+			    (isalpha(name[5]) && islower(name[5])) ||
+			    (isalpha(name[6]) && islower(name[6])) ||
+			    (isalpha(name[7]) && islower(name[7])))
+				fprintf(stderr, "** Warning ** : %s is not "
+				        "EFI 1.10 compliant\n", name);
+		}
 	}
 }
 
@@ -528,7 +560,7 @@
 	int i;
 	printf("BootOrder: ");
 	for (i=0; i<length; i++) {
-		printf("%04x", order[i]);
+		printf("%04X", order[i]);
 		if (i < (length-1))
 			printf(",");
 	}
@@ -572,7 +604,7 @@
 {
 	list_t *pos;
 	var_entry_t *boot;
-	char description[80];
+	char description[80], name[9];
 	EFI_LOAD_OPTION *load_option;
 	EFI_DEVICE_PATH *path;
 	char text_path[1024], *p;
@@ -586,7 +618,12 @@
 				load_option->description, sizeof(description));
 		memset(text_path, 0, sizeof(text_path));
 		path = load_option_path(load_option);
-		printf("Boot%04x", boot->num);
+		if (boot->name)
+			snprintf(name, 9, "%s", boot->name->d_name);
+		else
+			snprintf(name, 9, "Boot%04X", boot->num);
+
+		printf("%s", name);
 		if (load_option->attributes & LOAD_OPTION_ACTIVE)
 			printf("* ");
 		else    printf("  ");
@@ -790,7 +827,7 @@
 			opts.delete_boot = 1;
 			break;
 		case 'b':
-			rc = sscanf(optarg, "%x", &num);
+			rc = sscanf(optarg, "%X", &num);
 			if (rc = 1) opts.bootnum = num;
 			break;
 		case 'c':
@@ -920,7 +957,7 @@
 	if (!opts.testfile) {
 		num_boot_names = read_boot_var_names(&boot_names);
 		read_vars(boot_names, num_boot_names, &boot_entry_list);
-		set_var_nums("Boot%04x-%*s", &boot_entry_list);
+		set_var_nums("Boot%04X-%*s", &boot_entry_list);
 
 		if (opts.delete_boot) {
 			if (opts.bootnum = -1)
@@ -972,11 +1009,11 @@
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


