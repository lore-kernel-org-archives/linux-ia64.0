From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 24 Nov 2003 21:00:43 +0000
Subject: Re: udelay() & preemption & drifty ITCs
Message-Id: <marc-linux-ia64-106970777429946@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106955914311295@msgid-missing>
In-Reply-To: <marc-linux-ia64-106955914311295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Nov 23, 2003 at 02:39:29PM -0800, Jesse Barnes wrote:
> Yep, it appears so.  I guess we need a 'preempt_disable/disable()' pair
> around the itc access.  Of course, callers under a spinlock are already
> protected, so maybe exposure to this problem isn't that large?

Here's the patch.  Compiles and boots, but I haven't made a test module
that illustrates this bug, so I haven't tested it.

Jesse

diff -Nru a/include/asm-ia64/delay.h b/include/asm-ia64/delay.h
--- a/include/asm-ia64/delay.h	Mon Nov 24 13:59:12 2003
+++ b/include/asm-ia64/delay.h	Mon Nov 24 13:59:12 2003
@@ -15,6 +15,7 @@
 #include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
+#include <linux/preempt.h>
 #include <linux/compiler.h>
 
 #include <asm/intrinsics.h>
@@ -32,8 +33,10 @@
 {
 	unsigned long result;
 
+	preempt_disable();
 	result = ia64_getreg(_IA64_REG_CR_ITM);
 	ia64_srlz_d();
+	preempt_enable();
 	return result;
 }
 
