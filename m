From: Horms <horms@verge.net.au>
Date: Wed, 20 Sep 2006 02:43:01 +0000
Subject: Kexec/Kdump: honour non-zero crashkernel offset.
Message-Id: <20060920024544.733881000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There seems to be a value in both allowing the kernel to determine
the base offset of the crashkernel automatically and allowing
users's to sepcify it.

The old behaviour on ia64, which is still the current behaviour on
most architectures is for the user to always specify the address.
Recently ia64 was changed so that it is always automatically determined.

With this patch the kernel automatically determines the offset if
the supplied value is 0, otherwise it uses the value provided.

This should probably be backed by a documentation change.

Signed-Off-By: Simon Horman <horms@verge.net.au>
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2006-09-20 10:56:28.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2006-09-20 10:58:06.000000000 +0900
@@ -257,7 +257,7 @@
 
 #ifdef CONFIG_KEXEC
 	/* crashkernel=size@offset specifies the size to reserve for a crash
-	 * kernel.(offset is ingored for keep compatibility with other archs)
+	 * kernel. If offset is 0, then it is determined automatically.
 	 * By reserving this memory we guarantee that linux
 	 * never set's it up as a DMA target.
 	 * Useful for holding code to do something appropriate
@@ -268,7 +268,7 @@
 		unsigned long base, size;
 		if (from) {
 			size = memparse(from + 12, &from);
-			if (size) {
+			if (size && !base) {
 				sort_regions(rsvd_region, n);
 				base = kdump_find_rsvd_region(size,
 				rsvd_region, n);

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

