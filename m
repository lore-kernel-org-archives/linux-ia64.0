From: Keith Owens <kaos@sgi.com>
Date: Thu, 26 Oct 2006 04:08:09 +0000
Subject: [ANNOUNCE] salinfo 1.2 is available
Message-Id: <27564.1161835689@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson (on Wed, 25 Oct 2006 14:18:27 -0500 (CDT)) wrote:
>[patch] Add dp bit to cache and bus check structs
>
>Rev 2.2 of Volume 2 of "Intel Itanium Architecture Software Developer's
>Manual" (January 2006) adds a dp bit to the cache_check and bus_check
>fields (pages 2:401-2:404).  This patch gets the structs back in sync 
>with the spec.

salinfo 1.2 has been updated to add the dp bit.  It also stops
logrotate creating new (empty) log files when old salinfo entries are
rotated out.

Temporary location: ftp://ftp.ocs.com.au/salinfo-1.2.tar.bz2
Bjorn will copy that to kernel.org later.

diff -urp salinfo-1.1/ChangeLog salinfo-1.2/ChangeLog
--- salinfo-1.1/ChangeLog	2006-02-14 01:14:06.000000000 +1100
+++ salinfo-1.2/ChangeLog	2006-10-26 13:46:44.442152523 +1000
@@ -1,3 +1,9 @@
+2006-10-26  Keith Owens  <kaos@sgi.com>
+
+	* Add 'dp' bit (Data poisoned on MBE).
+	* Do not create new files when logrotating old salinfo records.
+	* Released as 1.2.
+
 2006-02-13  Keith Owens  <kaos@sgi.com>
 
 	* mandir patch to Makefile, from SuSE.
diff -urp salinfo-1.1/mca.c salinfo-1.2/mca.c
--- salinfo-1.1/mca.c	2006-02-13 15:24:50.000000000 +1100
+++ salinfo-1.2/mca.c	2006-10-26 13:44:36.926904621 +1000
@@ -428,6 +428,8 @@ cache_check_info_print (int i, sal_log_m
 			info->mesi, info->mesi < ARRAY_SIZE(mesi) ? mesi[info->mesi] : "reserved");
 	if (info->wiv)
 		iprintf(", Way: %d, Index: %d", info->way, info->index);
+	if (info->dp)
+		iprintf(", Data poisoned on MBE");
 	iprintf("\n");
 	mod_error_info_common_print(cache_check_info, info);
 	--indent;
@@ -525,6 +527,8 @@ bus_check_info_print (int i, sal_log_mod
 	iprintf(", Type: %d (%s)",
 		info->type, info->type < ARRAY_SIZE(type) ? type[info->type] : "reserved");
 	iprintf(", Severity: %d, Hierarchy: %d", info->sev, info->hier);
+	if (info->dp)
+		iprintf(", Data poisoned on MBE");
 	iprintf(", Status information: %d (%s)",
 		info->bsi, info->bsi < ARRAY_SIZE(bsi) ? bsi[info->bsi] : "processor specific");
 	iprintf("\n");
diff -urp salinfo-1.1/pal.h salinfo-1.2/pal.h
--- salinfo-1.1/pal.h	2003-11-06 13:28:38.000000000 +1100
+++ salinfo-1.2/pal.h	2006-10-26 13:42:56.740069819 +1000
@@ -150,10 +150,12 @@ typedef struct pal_cache_check_info_s {
 						 * error occurred
 						 */
 			wiv		: 1,	/* Way field valid */
-			reserved2	: 10,
+			reserved2	: 1,
+			dp		: 1,	/* Data poisoned on MBE */
+			reserved3	: 8,
 
 			index		: 20,	/* Cache line index */
-			reserved3	: 2,
+			reserved4	: 2,
 
 			is		: 1,	/* instruction set (1 = ia32) */
 			iv		: 1,	/* instruction set field valid */
@@ -220,7 +222,7 @@ typedef struct pal_bus_check_info_s {
 			type		: 8,	/* Bus xaction type*/
 			sev		: 5,	/* Bus error severity*/
 			hier		: 2,	/* Bus hierarchy level */
-			reserved1	: 1,
+			dp		: 1,	/* Data poisoned on MBE */
 			bsi		: 8,	/* Bus error status
 						 * info
 						 */
diff -urp salinfo-1.1/salinfo-logrotate.d-salinfo_decode salinfo-1.2/salinfo-logrotate.d-salinfo_decode
--- salinfo-1.1/salinfo-logrotate.d-salinfo_decode	2004-10-04 16:03:27.000000000 +1000
+++ salinfo-1.2/salinfo-logrotate.d-salinfo_decode	2006-10-26 13:41:46.309326668 +1000
@@ -4,6 +4,7 @@
     weekly
     notifempty
     missingok
+    nocreate
 }
 
 /var/log/salinfo/raw/* {
@@ -12,4 +13,5 @@
     weekly
     notifempty
     missingok
+    nocreate
 }
diff -urp salinfo-1.1/salinfo.spec salinfo-1.2/salinfo.spec
--- salinfo-1.1/salinfo.spec	2006-02-13 15:22:16.000000000 +1100
+++ salinfo-1.2/salinfo.spec	2006-10-26 13:46:57.304463016 +1000
@@ -1,6 +1,6 @@
 Summary: Decode IA64 SAL records
 Name: salinfo
-Version: 1.1
+Version: 1.2
 Release: 1
 License: GPL
 Group: Utilities/System

