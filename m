From: Keith Owens <kaos@sgi.com>
Date: Mon, 15 Mar 2004 07:07:31 +0000
Subject: Re: [patch] 2.6.4 Decode salinfo oemdata via prom
Message-Id: <5885.1079334451@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2724.1079310544@kao2.melbourne.sgi.com>
In-Reply-To: <2724.1079310544@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

New boilerplate.

SN2 platforms provide oemdata in salinfo records.  The decode of that
oemdata is done via prom routines.  This patch provides the interface
from user space through the kernel into the prom to do the oem decode.

Index: linux-2.6.4/arch/ia64/sn/kernel/mca.c
--- linux-2.6.4.orig/arch/ia64/sn/kernel/mca.c	Thu Mar 11 13:55:23 2004
+++ linux-2.6.4/arch/ia64/sn/kernel/mca.c	Mon Mar 15 18:05:52 2004
@@ -1,17 +1,15 @@
 /*
- * File:	mca.c
- * Purpose:	SN specific MCA code.
- *
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2001-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
+#include <linux/vmalloc.h>
 #include <asm/sn/sgi.h>
 #include <asm/mca.h>
 #include <asm/sal.h>
@@ -30,41 +28,43 @@
 struct timer_list sn_cpei_timer;
 void sn_init_cpei_timer(void);
 
+/* Printing oemdata from mca uses data that is not passed through SAL, it is
+ * global.  Only one user at a time.
+ */
+static DECLARE_MUTEX(sn_oemdata_mutex);
+static u8 **sn_oemdata;
+static u64 *sn_oemdata_size, sn_oemdata_bufsize;
 
 /*
  * print_hook
  *
  * This function is the callback routine that SAL calls to log error
- * info for platform errors. 
+ * info for platform errors.  buf is appended to sn_oemdata, resizing as
+ * required.
  */
 static int
 print_hook(const char *fmt, ...)
 {
-	static int	newline=1;
-	char		buf[400], *p;
-	va_list		args;
-	int		len=0;
-
-
+	char buf[400];
+	int len;
+	va_list args;
 	va_start(args, fmt);
-	if (newline) {
-		strcpy(buf, "+ ");
-		len += 2;
-	}
-	len += vsnprintf(buf+len, sizeof(buf)-len, fmt, args);
-
-	/* Prefix each line with "+ " to be consistent with mca.c. */
-	p = buf;
-	while ((p=strchr(p, '\n')) && *++p != '\0') {
-		memmove(p+2, p, 1+strlen(p));
-		strncpy(p, "+ ", 2);
-		len += 2;
-	}
-	newline = (p != 0);
-
+	vsnprintf(buf, sizeof(buf), fmt, args);
 	va_end(args);
-	printk("%s", buf);
-	return len;
+	len = strlen(buf);
+	while (*sn_oemdata_size + len + 1 > sn_oemdata_bufsize) {
+		u8 *newbuf = vmalloc(sn_oemdata_bufsize += 1000);
+		if (!newbuf) {
+			printk(KERN_ERR "%s: unable to extend sn_oemdata\n", __FUNCTION__);
+			return 0;
+		}
+		memcpy(newbuf, *sn_oemdata, *sn_oemdata_size);
+		vfree(*sn_oemdata);
+		*sn_oemdata = newbuf;
+	}
+	memcpy(*sn_oemdata + *sn_oemdata_size, buf, len + 1);
+	*sn_oemdata_size += len;
+	return 0;
 }
 
 
@@ -95,6 +95,43 @@
 {
 	init_timer(&sn_cpei_timer);
 	sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
-        sn_cpei_timer.function = sn_cpei_timer_handler;
+	sn_cpei_timer.function = sn_cpei_timer_handler;
 	add_timer(&sn_cpei_timer);
 }
+
+static int
+sn_platform_plat_specific_err_print(const u8 *sect_header, u8 **oemdata, u64 *oemdata_size)
+{
+	sal_log_plat_specific_err_info_t *psei = (sal_log_plat_specific_err_info_t *)sect_header;
+	if (!psei->valid.oem_data)
+		return 0;
+	down(&sn_oemdata_mutex);
+	sn_oemdata = oemdata;
+	sn_oemdata_size = oemdata_size;
+	ia64_sn_plat_specific_err_print(print_hook, (char *)psei);
+	up(&sn_oemdata_mutex);
+	return 0;
+}
+
+/* Callback when userspace salinfo wants to decode oem data via the platform
+ * kernel and/or prom.
+ */
+int sn_salinfo_platform_oemdata(const u8 *sect_header, u8 **oemdata, u64 *oemdata_size)
+{
+	efi_guid_t guid = *(efi_guid_t *)sect_header;
+	*oemdata_size = 0;
+	sn_oemdata_bufsize = 0;
+	vfree(*oemdata);
+	*oemdata = NULL;
+	if (efi_guidcmp(guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0)
+		return sn_platform_plat_specific_err_print(sect_header, oemdata, oemdata_size);
+	return 0;
+}
+
+static int __init sn_salinfo_init(void)
+{
+	salinfo_platform_oemdata = &sn_salinfo_platform_oemdata;
+	return 0;
+}
+
+module_init(sn_salinfo_init)

