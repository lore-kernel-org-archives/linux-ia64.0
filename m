From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 09 Jan 2017 23:20:25 +0000
Subject: [PATCH RFC] ia64: export ia64_delay_loop for "allmodconfig" coverage
Message-Id: <20170109232025.18859-1-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org

Currently we see:

ERROR: "ia64_delay_loop" [drivers/spi/spi-thunderx.ko] undefined!
ERROR: "ia64_delay_loop" [drivers/net/phy/mdio-cavium.ko] undefined!

...on ia64 allmodconfig builds.  While it is true nobody would ever
load/use these !ia64 drivers on ia64 kit, they probably won't be the
only ones enabled via COMPILE_TEST or non-strict dependencies as time
goes on.  So just export the symbol, right from the assembly file,
now that we can do that.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[Note: Al had this export in the early version of a patch in patchwork
 https://patchwork.kernel.org/patch/8166731/  but then the export was
 removed in the mainline version in e007c53397ac -- hence RFC tag. ]

 arch/ia64/kernel/head.S | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index c9b5e942f671..640294cbe227 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -993,6 +993,7 @@ GLOBAL_ENTRY(ia64_delay_loop)
 	mov ar.lc=r2
 	br.ret.sptk.many rp
 END(ia64_delay_loop)
+EXPORT_SYMBOL(ia64_delay_loop)
 
 /*
  * Return a CPU-local timestamp in nano-seconds.  This timestamp is
-- 
2.11.0

