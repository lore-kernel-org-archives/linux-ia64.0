From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Oct 2004 15:31:20 +0000
Subject: another sparse-detected bug-fix
Message-Id: <200410041531.i94FVKMF031506@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Here is another amazing one: the access_ok() call in
csum_partial_copy_from_user() had the arguments in the wrong order!
We never noticed because "len" is always a small value, and hence
never triggered the address-limit check and hence access_ok() always
returned TRUE...

	--david

---
ia64: fix argument-order in access_ok() call from csum_partial_copy_from_user()

Another sparse-detected bug.

Signed-off-by: davidm@hpl.hp.com

=== arch/ia64/lib/csum_partial_copy.c 1.6 vs edited ==--- 1.6/arch/ia64/lib/csum_partial_copy.c	2003-10-17 22:51:39 -07:00
+++ edited/arch/ia64/lib/csum_partial_copy.c	2004-10-04 08:25:58 -07:00
@@ -1,7 +1,7 @@
 /*
  * Network Checksum & Copy routine
  *
- * Copyright (C) 1999, 2003 Hewlett-Packard Co
+ * Copyright (C) 1999, 2003-2004 Hewlett-Packard Co
  *	Stephane Eranian <eranian@hpl.hp.com>
  *
  * Most of the code has been imported from Linux/Alpha
@@ -129,10 +129,10 @@
 }
 
 unsigned int
-csum_partial_copy_from_user(const char *src, char *dst, int len,
-			    unsigned int sum, int *errp)
+csum_partial_copy_from_user (const char __user *src, char *dst, int len,
+			     unsigned int sum, int *errp)
 {
-	if (!access_ok(src, len, VERIFY_READ)) {
+	if (!access_ok(VERIFY_READ, src, len)) {
 		*errp = -EFAULT;
 		memset(dst, 0, len);
 		return sum;
