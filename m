From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 08 Mar 2005 00:24:17 +0000
Subject: Re: efibootmgr fixes for EFI 1.10
Message-Id: <1110241458.353.7.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1109719371.12409.81.camel@tdi>
In-Reply-To: <1109719371.12409.81.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[I sent this earlier, but it seems to have gotten lost, sorry for dups]

On Mon, 2005-03-07 at 20:29 +0100, Thibaut VARENE wrote:

> I'd be quite interested in having these changes into Ubuntu (and possibly
> into Debian as well, assuming Bdale wants them), so I'd like to know
> whether you have updated version of that patch you're happy with?

   Yep, meant to mail it out last week, but kept forgetting.  Here's the
patch with fixes per Andreas' comments.  I think it's good to go.
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
+++ efibootmgr-0.5.0/src/efibootmgr/efibootmgr.c	2005-03-01 17:16:55.496618382 -0700
@@ -32,6 +32,7 @@
 
 #define _GNU_SOURCE
 
+#include <ctype.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -215,8 +216,8 @@
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
@@ -228,9 +229,21 @@
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
 
@@ -398,13 +411,20 @@
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
@@ -424,11 +444,21 @@
 	list_t *pos;
 	var_entry_t *var;
 	int num=0, rc;
+	char *name;
 
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
+			    (isalpha(name[7]) && islower(name[7])))
+				fprintf(stderr, "** Warning ** : %.8s is not "
+				        "EFI 1.10 compliant\n", name);
+		}
 	}
 }
 
@@ -528,7 +558,7 @@
 	int i;
 	printf("BootOrder: ");
 	for (i=0; i<length; i++) {
-		printf("%04x", order[i]);
+		printf("%04X", order[i]);
 		if (i < (length-1))
 			printf(",");
 	}
@@ -586,7 +616,11 @@
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
@@ -790,7 +824,7 @@
 			opts.delete_boot = 1;
 			break;
 		case 'b':
-			rc = sscanf(optarg, "%x", &num);
+			rc = sscanf(optarg, "%X", &num);
 			if (rc = 1) opts.bootnum = num;
 			break;
 		case 'c':
@@ -920,7 +954,7 @@
 	if (!opts.testfile) {
 		num_boot_names = read_boot_var_names(&boot_names);
 		read_vars(boot_names, num_boot_names, &boot_entry_list);
-		set_var_nums("Boot%04x-%*s", &boot_entry_list);
+		set_var_nums("Boot%04X-%*s", &boot_entry_list);
 
 		if (opts.delete_boot) {
 			if (opts.bootnum = -1)
@@ -972,11 +1006,11 @@
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


