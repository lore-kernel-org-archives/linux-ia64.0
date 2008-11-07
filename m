From: Jay Lan <jlan@sgi.com>
Date: Fri, 07 Nov 2008 02:32:32 +0000
Subject: [PATCH] Reserve elfcorehdr memory in CONFIG_CRASH_DUMP
Message-Id: <4913A8C0.8090108@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050900080006010709070406"
List-Id: <linux-ia64.vger.kernel.org>
To: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: Simon Horman <horms@verge.net.au>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>

This is a multi-part message in MIME format.
--------------050900080006010709070406
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

IA64 kdump kernel failed to initialize /proc/vmcore in 2.6.28-rc2.
A bug was introduced in this patch commit:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=d9a9855d0b06ca6d6cc92596fedcc03f8512e062

The problem was that the call to reserve_elfcorehdr() should be placed
in CONFIG_CRASH_DUMP rather than in CONFIG_CRASH_KERNEL, which does
not exist.

The patch fixes the problem.

Signed-off-by: Jay Lan <jlan@sgi.com>

--------------050900080006010709070406
Content-Type: text/plain;
 name="reserve-elfcorehdr-in-CRASH_DUMP"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="reserve-elfcorehdr-in-CRASH_DUMP"

---
 arch/ia64/kernel/setup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux/arch/ia64/kernel/setup.c
===================================================================
--- linux.orig/arch/ia64/kernel/setup.c	2008-11-06 18:01:18.000000000 -0800
+++ linux/arch/ia64/kernel/setup.c	2008-11-06 18:05:42.047332827 -0800
@@ -359,7 +359,7 @@ reserve_memory (void)
 	}
 #endif
 
-#ifdef CONFIG_CRASH_KERNEL
+#ifdef CONFIG_CRASH_DUMP
 	if (reserve_elfcorehdr(&rsvd_region[n].start,
 			       &rsvd_region[n].end) == 0)
 		n++;

--------------050900080006010709070406--
