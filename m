From: jes@trained-monkey.org (Jes Sorensen)
Date: Wed, 11 Jan 2006 11:52:32 +0000
Subject: [patch] remove unused semaphore from arch/ia64/hp/sim/simserial.c
Message-Id: <17348.61824.49889.569928@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@osdl.org
Cc: akpm@osdl.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


Remove unsued semaphore declaration.

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 arch/ia64/hp/sim/simserial.c |    1 -
 1 files changed, 1 deletion(-)

Index: linux-2.6.15-rc7-quilt/arch/ia64/hp/sim/simserial.c
=================================--- linux-2.6.15-rc7-quilt.orig/arch/ia64/hp/sim/simserial.c
+++ linux-2.6.15-rc7-quilt/arch/ia64/hp/sim/simserial.c
@@ -107,7 +107,6 @@
 static struct console *console;
 
 static unsigned char *tmp_buf;
-static DECLARE_MUTEX(tmp_buf_sem);
 
 extern struct console *console_drivers; /* from kernel/printk.c */
 
