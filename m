From: Keith Owens <kaos@sgi.com>
Date: Thu, 30 Oct 2003 08:43:11 +0000
Subject: [patch 4/4] kernel salinfo changes
Message-Id: <marc-linux-ia64-106750344518501@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

patch 4 - Not to be added to the kernel yet.  This is an example of
          decoding the oem data via kernel/prom.

--- 2.4.23-pre8-cset-1.1069.1.143-to-1.1108/arch/ia64/sn/kernel/mca.c	Tue Aug 26 09:46:18 2003
+++ lbs/linux/arch/ia64/sn/kernel/mca.c	Thu Oct 30 15:43:51 2003
@@ -36,6 +36,8 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
+#include <linux/vmalloc.h>
+#include <asm/machvec.h>
 #include <asm/mca.h>
 #include <asm/sal.h>
 #include <asm/sn/sn_sal.h>
@@ -53,6 +55,42 @@
 struct timer_list sn_cpei_timer;
 void sn_init_cpei_timer(void);
 
+/* Printing oemdata from mca uses data that is not passed through SAL, it is
+ * global.  Only one user at a time.
+ */
+static DECLARE_MUTEX(sn_oemdata_mutex);
+static prfunc_t sn_oemdata_prfunc;
+static u8 **sn_oemdata;
+static u64 *sn_oemdata_size, sn_oemdata_bufsize;
+
+/* Called as the "printk" routine via sn_platform_plat_specific_err_print,
+ * ia64_sn_plat_specific_err_print through SAL to print_hook.  It only handles
+ * a print of '"%s", buf'.  buf is appended to sn_oemdata, resizing as required.
+ */
+static int
+sn_oemdata_print(const char *fmt, ...)
+{
+	va_list args;
+	char *buf;
+	int len;
+	va_start(args, fmt);
+	buf = va_arg(args, char *);
+	va_end(args);
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
+	return len;
+}
 
 /*
  * print_hook
@@ -86,7 +124,7 @@
 	newline = (p != 0);
 
 	va_end(args);
-	printk("%s", buf);
+	sn_oemdata_prfunc("%s", buf);	/* args must be '%s", buf' */
 	return len;
 }
 
@@ -100,7 +138,10 @@
 void
 ia64_sn2_platform_plat_specific_err_print(int header_len, int sect_len, u8 *p_data, prfunc_t prfunc)
 {
+	down(&sn_oemdata_mutex);
+	sn_oemdata_prfunc = prfunc;
 	ia64_sn_plat_specific_err_print(print_hook, p_data - sect_len);
+	up(&sn_oemdata_mutex);
 }
 
 
@@ -132,3 +173,41 @@
         sn_cpei_timer.function = sn_cpei_timer_handler;
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
+	sn_oemdata_prfunc = &sn_oemdata_print;
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

