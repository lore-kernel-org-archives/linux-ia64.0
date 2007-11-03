From: Roel Kluin <12o3l@tiscali.nl>
Date: Sat, 03 Nov 2007 23:13:43 +0000
Subject: [PATCH] Also iounmap in error path in arch/ia64/kernel/cyclone.c
Message-Id: <472D00A7.1080409@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

base is a local u64. use_cyclone a global int.
--
Also iounmap in error path

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index 790ef0d..d23acf0 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -59,13 +59,13 @@ int __init init_cyclone_clock(void)
 		return -ENODEV;
 	}
 	base = readq(reg);
+	iounmap(reg);
 	if(!base){
 		printk(KERN_ERR "Summit chipset: Could not find valid CBAR"
 				" value.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
-	iounmap(reg);
 
 	/* setup PMCC */
 	offset = (base + CYCLONE_PMCC_OFFSET);
