From: Keith Owens <kaos@sgi.com>
Date: Sat, 23 Apr 2005 07:04:41 +0000
Subject: [patch 2.6.12-rc2] SAL to OS callbacks cannot call sleeping functions
Message-Id: <10909.1114239881@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <9738.1112966561@ocs3.ocs.com.au>
In-Reply-To: <9738.1112966561@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Resend from April 8, it has not appeared in ia64 pulls yet.

When SAL calls back into the OS, the OS code is running with preempt
disabled so it cannot call sleeping functions.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/sn/kernel/mca.c
=================================--- linux.orig/arch/ia64/sn/kernel/mca.c	2005-04-08 12:59:26.000000000 +1000
+++ linux/arch/ia64/sn/kernel/mca.c	2005-04-08 13:29:34.000000000 +1000
@@ -37,6 +37,11 @@ static u64 *sn_oemdata_size, sn_oemdata_
  * This function is the callback routine that SAL calls to log error
  * info for platform errors.  buf is appended to sn_oemdata, resizing as
  * required.
+ * Note: this is a SAL to OS callback, running under the same rules as the SAL
+ * code.  SAL calls are run with preempt disabled so this routine must not
+ * sleep.  vmalloc can sleep so print_hook cannot resize the output buffer
+ * itself, instead it must set the required size and return to let the caller
+ * resize the buffer then redrive the SAL call.
  */
 static int print_hook(const char *fmt, ...)
 {
@@ -47,18 +52,8 @@ static int print_hook(const char *fmt, .
 	vsnprintf(buf, sizeof(buf), fmt, args);
 	va_end(args);
 	len = strlen(buf);
-	while (*sn_oemdata_size + len + 1 > sn_oemdata_bufsize) {
-		u8 *newbuf = vmalloc(sn_oemdata_bufsize += 1000);
-		if (!newbuf) {
-			printk(KERN_ERR "%s: unable to extend sn_oemdata\n",
-			       __FUNCTION__);
-			return 0;
-		}
-		memcpy(newbuf, *sn_oemdata, *sn_oemdata_size);
-		vfree(*sn_oemdata);
-		*sn_oemdata = newbuf;
-	}
-	memcpy(*sn_oemdata + *sn_oemdata_size, buf, len + 1);
+	if (*sn_oemdata_size + len <= sn_oemdata_bufsize)
+		memcpy(*sn_oemdata + *sn_oemdata_size, buf, len);
 	*sn_oemdata_size += len;
 	return 0;
 }
@@ -98,7 +93,20 @@ sn_platform_plat_specific_err_print(cons
 	sn_oemdata = oemdata;
 	sn_oemdata_size = oemdata_size;
 	sn_oemdata_bufsize = 0;
-	ia64_sn_plat_specific_err_print(print_hook, (char *)sect_header);
+	*sn_oemdata_size = PAGE_SIZE;	/* first guess at how much data will be generated */
+	while (*sn_oemdata_size > sn_oemdata_bufsize) {
+		u8 *newbuf = vmalloc(*sn_oemdata_size);
+		if (!newbuf) {
+			printk(KERN_ERR "%s: unable to extend sn_oemdata\n",
+			       __FUNCTION__);
+			return 1;
+		}
+		vfree(*sn_oemdata);
+		*sn_oemdata = newbuf;
+		sn_oemdata_bufsize = *sn_oemdata_size;
+		*sn_oemdata_size = 0;
+		ia64_sn_plat_specific_err_print(print_hook, (char *)sect_header);
+	}
 	up(&sn_oemdata_mutex);
 	return 0;
 }


