From: Bill Pemberton <wfp5p@virginia.edu>
Date: Mon, 19 Nov 2012 18:19:32 +0000
Subject: [PATCH 023/493] ia64: iosapic: remove CONFIG_HOTPLUG ifdefs
Message-Id: <1353349642-3677-23-git-send-email-wfp5p@virginia.edu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove conditional code based on CONFIG_HOTPLUG being false.  It's
always on now in preparation of it going away as an option.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Tony Luck <tony.luck@intel.com>  PL...)
Cc: Fenghua Yu <fenghua.yu@intel.com>  PL...)
Cc: linux-ia64@vger.kernel.org  PL...)
---
 arch/ia64/include/asm/iosapic.h | 4 ----
 arch/ia64/kernel/iosapic.c      | 2 --
 2 files changed, 6 deletions(-)

diff --git a/arch/ia64/include/asm/iosapic.h b/arch/ia64/include/asm/iosapic.h
index b9c102e..614b338 100644
--- a/arch/ia64/include/asm/iosapic.h
+++ b/arch/ia64/include/asm/iosapic.h
@@ -89,11 +89,7 @@ static inline void iosapic_eoi(char __iomem *iosapic, u32 vector)
 extern void __init iosapic_system_init (int pcat_compat);
 extern int __devinit iosapic_init (unsigned long address,
 				    unsigned int gsi_base);
-#ifdef CONFIG_HOTPLUG
 extern int iosapic_remove (unsigned int gsi_base);
-#else
-#define iosapic_remove(gsi_base)				(-EINVAL)
-#endif /* CONFIG_HOTPLUG */
 extern int gsi_to_irq (unsigned int gsi);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
 				  unsigned long trigger);
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index ef4b5d8..12b1234 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -1070,7 +1070,6 @@ iosapic_init (unsigned long phys_addr, unsigned int gsi_base)
 	return 0;
 }
 
-#ifdef CONFIG_HOTPLUG
 int
 iosapic_remove (unsigned int gsi_base)
 {
@@ -1098,7 +1097,6 @@ iosapic_remove (unsigned int gsi_base)
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 	return err;
 }
-#endif /* CONFIG_HOTPLUG */
 
 #ifdef CONFIG_NUMA
 void __devinit
-- 
1.8.0

