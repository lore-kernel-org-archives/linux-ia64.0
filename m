From: Adrian Bunk <bunk@kernel.org>
Date: Fri, 08 Aug 2008 16:34:45 +0000
Subject: [7/17] ia64: use bcd2bin/bin2bcd
Message-Id: <20080808163445.GN14495@cs181140183.pp.htv.fi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Brownell <david-b@pacbell.net>

This patch changes ia64 to use the new bcd2bin/bin2bcd functions instead 
of the obsolete BCD2BIN/BIN2BCD macros.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
fb54890949dadb16520ed7d3f9c7eb2b89abb34e 
diff --git a/arch/ia64/include/asm/sal.h b/arch/ia64/include/asm/sal.h
index 89594b4..ea310c0 100644
--- a/arch/ia64/include/asm/sal.h
+++ b/arch/ia64/include/asm/sal.h
@@ -236,7 +236,7 @@ extern struct ia64_sal_desc_ptc *ia64_ptc_domain_info;
 
 extern unsigned short sal_revision;	/* supported SAL spec revision */
 extern unsigned short sal_version;	/* SAL version; OEM dependent */
-#define SAL_VERSION_CODE(major, minor) ((BIN2BCD(major) << 8) | BIN2BCD(minor))
+#define SAL_VERSION_CODE(major, minor) ((bin2bcd(major) << 8) | bin2bcd(minor))
 
 extern const char *ia64_sal_strerror (long status);
 extern void ia64_sal_init (struct ia64_sal_systab *sal_systab);

