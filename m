From: Keith Owens <kaos@sgi.com>
Date: Thu, 19 Feb 2004 06:05:26 +0000
Subject: [patch] 2.4.25 Print SN oemdata through the prom
Message-Id: <8309.1077170726@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

salinfo_decode can call into the kernel to decode oem data, via the
optional and platform specific program called salinfo_decode_oem.  SGI
SN platforms decode oemdata by calling from kernel into the prom.

--- 2.4.25-ia64-040218/arch/ia64/sn/kernel/mca.c	Thu Feb 19 08:50:02 2004
+++ 2.4.25-ia64-040218/arch/ia64/sn/kernel/mca.c	Sat Nov  8 14:24:51 2003
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
@@ -86,11 +124,28 @@ print_hook(const char *fmt, ...)
 	newline = (p != 0);
 
 	va_end(args);
-	printk("%s", buf);
+	sn_oemdata_prfunc("%s", buf);	/* args must be '%s", buf' */
 	return len;
 }
 
 
+
+/*
+ * ia64_sn2_platform_plat_specific_err_print
+ *
+ * Called by the MCA handler to log platform-specific errors.
+ */
+void
+ia64_sn2_platform_plat_specific_err_print(int header_len, int sect_len, u8 *p_data, prfunc_t prfunc)
+{
+	down(&sn_oemdata_mutex);
+	sn_oemdata_prfunc = prfunc;
+	ia64_sn_plat_specific_err_print(print_hook, p_data - sect_len);
+	up(&sn_oemdata_mutex);
+}
+
+
+
 static void
 sn_cpei_handler(int irq, void *devid, struct pt_regs *regs)
 {
@@ -118,3 +173,41 @@ sn_init_cpei_timer() {
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
+        return 0;
+}
+
+module_init(sn_salinfo_init)

