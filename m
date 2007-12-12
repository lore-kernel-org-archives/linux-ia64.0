From: "Jan Beulich" <jbeulich@novell.com>
Date: Wed, 12 Dec 2007 15:20:13 +0000
Subject: [PATCH] ia64: remove dead code
Message-Id: <47600A3D.76E4.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Neither __cpu_down() nor __cpu_die() are being referenced without
CONFIG_HOTPLUG_CPU.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

 arch/ia64/kernel/smpboot.c |   11 -----------
 1 file changed, 11 deletions(-)

--- linux-2.6.24-rc5/arch/ia64/kernel/smpboot.c	2007-12-12 12:27:11.000000000 +0100
+++ 2.6.24-rc5-ia64-cpu-die/arch/ia64/kernel/smpboot.c	2007-12-07 16:12:33.000000000 +0100
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



