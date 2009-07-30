From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 30 Jul 2009 15:42:13 +0000
Subject: [PATCH] iosapic: missing test after ioremap()?
Message-Id: <4A71BF55.3010006@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Missing test after ioremap()

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Shouldn't we test whether ioremap failed?

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index c48b03f..dab4d39 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -1072,6 +1072,10 @@ iosapic_init (unsigned long phys_addr, unsigned int gsi_base)
 	}
 
 	addr = ioremap(phys_addr, 0);
+	if (addr = NULL) {
+		spin_unlock_irqrestore(&iosapic_lock, flags);
+		return -ENOMEM;
+	}
 	ver = iosapic_version(addr);
 	if ((err = iosapic_check_gsi_range(gsi_base, ver))) {
 		iounmap(addr);
