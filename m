From: Keith Owens <kaos@sgi.com>
Date: Tue, 15 Mar 2005 00:42:57 +0000
Subject: Re: kernel update (relative to 2.4.29)
Message-Id: <10378.1110847377@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110843799.4088.38.camel@eeyore>
In-Reply-To: <1110843799.4088.38.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 14 Mar 2005 16:43:19 -0700, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>The ia64 kernel patch for Linux 2.4.29 is available here:
>
>  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.29-ia64-050312.diff.gz
>    - add unw_unwind_to_user() sanity check (Keith Owens).

This patch brings the unw_unwind_to_user() fix in 2.4.29 in line with
linux-ia64-test-2.6.12, including
http://lia64.bkbits.net:8080/linux-ia64-test-2.6.12/cset@42321d3fEXH4rqojRfbWYforyFKPWw?nav=index.html|ChangeSet@-4d

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: 2.4.29-ia64-050312/arch/ia64/kernel/unwind.c
=================================--- 2.4.29-ia64-050312.orig/arch/ia64/kernel/unwind.c	2005-03-15 11:36:40.000000000 +1100
+++ 2.4.29-ia64-050312/arch/ia64/kernel/unwind.c	2005-03-15 11:36:42.000000000 +1100
@@ -48,6 +48,8 @@
 
 #define MIN(a,b)	((a) < (b) ? (a) : (b))
 #define p5		5
+#define PRED_USER_STACK pUser
+#define p3		3	/* for pUser */
 
 #define UNW_LOG_CACHE_SIZE	7	/* each unw_script is ~256 bytes in size */
 #define UNW_CACHE_SIZE		(1 << UNW_LOG_CACHE_SIZE)
@@ -1916,27 +1918,30 @@ EXPORT_SYMBOL(unw_unwind);
 int
 unw_unwind_to_user (struct unw_frame_info *info)
 {
-	unsigned long ip, sp;
+	unsigned long ip, sp, pr = 0;
 
 	while (unw_unwind(info) >= 0) {
-		if (unw_get_rp(info, &ip) < 0) {
-			unw_get_ip(info, &ip);
-			UNW_DPRINT(0, "unwind.%s: failed to read return pointer (ip=0x%lx)\n",
-				   __FUNCTION__, ip);
-			return -1;
-		}
 		unw_get_sp(info, &sp);
-		if (sp >= (unsigned long)info->task + IA64_STK_OFFSET)
+		if ((long)((unsigned long)info->task + IA64_STK_OFFSET - sp)
+		    < IA64_PT_REGS_SIZE) {
+			UNW_DPRINT(0, "unwind.%s: ran off the top of the kernel stack\n",
+				   __FUNCTION__);
 			break;
-		/*
-		 * We don't have unwind info for the gate page, so we consider that part
-		 * of user-space for the purpose of unwinding.
-		 */
-		if (ip < GATE_ADDR + PAGE_SIZE)
+		}
+		if (unw_is_intr_frame(info) &&
+		    (pr & (1UL << PRED_USER_STACK)))
 			return 0;
+		if (unw_get_pr (info, &pr) < 0) {
+			unw_get_rp(info, &ip);
+			UNW_DPRINT(0, "unwind.%s: failed to read "
+				   "predicate register (ip=0x%lx)\n",
+				__FUNCTION__, ip);
+			return -1;
+		}
 	}
 	unw_get_ip(info, &ip);
-	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n", __FUNCTION__, ip);
+	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n",
+		   __FUNCTION__, ip);
 	return -1;
 }
 EXPORT_SYMBOL(unw_unwind_to_user);

