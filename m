From: akpm@linux-foundation.org
Date: Tue, 05 Feb 2008 07:43:02 +0000
Subject: [patch 1/4] ia64: remove dead code
Message-Id: <200802050742.m157ghUl010214@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Jan Beulich" <jbeulich@novell.com>

Neither __cpu_down() nor __cpu_die() are being referenced without
CONFIG_HOTPLUG_CPU.

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/smpboot.c |   11 -----------
 1 file changed, 11 deletions(-)

diff -puN arch/ia64/kernel/smpboot.c~ia64-remove-dead-code arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c~ia64-remove-dead-code
+++ a/arch/ia64/kernel/smpboot.c
@@ -767,17 +767,6 @@ void __cpu_die(unsigned int cpu)
 	}
  	printk(KERN_ERR "CPU %u didn't die...\n", cpu);
 }
-#else /* !CONFIG_HOTPLUG_CPU */
-int __cpu_disable(void)
-{
-	return -ENOSYS;
-}
-
-void __cpu_die(unsigned int cpu)
-{
-	/* We said "no" in __cpu_disable */
-	BUG();
-}
 #endif /* CONFIG_HOTPLUG_CPU */
 
 void
_
