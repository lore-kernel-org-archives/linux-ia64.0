From: Horms <horms@verge.net.au>
Date: Wed, 20 Sep 2006 02:43:02 +0000
Subject: Kexec/Kdump: tidy up crashkernel comment
Message-Id: <20060920024545.049720000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-Off-By: Simon Horman <horms@verge.net.au>
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2006-09-20 10:59:32.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2006-09-20 11:01:00.000000000 +0900
@@ -258,10 +258,9 @@
 #ifdef CONFIG_KEXEC
 	/* crashkernel=size@offset specifies the size to reserve for a crash
 	 * kernel. If offset is 0, then it is determined automatically.
-	 * By reserving this memory we guarantee that linux
-	 * never set's it up as a DMA target.
-	 * Useful for holding code to do something appropriate
-	 * after a kernel panic.
+	 * By reserving this memory we guarantee that linux never sets it
+	 * up as a DMA target. Useful for holding code to do something
+	 * appropriate after a kernel panic.
 	 */
 	{
 		char *from = strstr(saved_command_line, "crashkernel=");

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

