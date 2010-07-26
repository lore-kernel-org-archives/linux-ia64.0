From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 26 Jul 2010 22:20:48 +0000
Subject: [RFC] increase ia64 static per cpu area
Message-Id: <4c4e0a40170612ea22@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've been trying to avoid this for a long time ... but per-cpu space
has slowly been growing.  Tejun has some patches in linux-next that
pre-reserve some space (PERCPU_DYNAMIC_EARLY_SIZE) for use before
slab comes online ... and this pushes ia64 above the 64K current
limit on static percpu space.

I could probably squeeze it back under (we are only over by 512 bytes).
But I don't think that I'll be able to squeeze it down enough to build
a comfortable breathing space - and I don't want to keep nibbling off
a dozen bytes here and there every time some generic code bumps us
back over the limit.

Next available supported page size is 256K ... so we have to quadruple
the available space - a bigger jump than I'd like. But perhaps it will
be enough to last a few more years before it needs to be increased again.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/include/asm/page.h b/arch/ia64/include/asm/page.h
index 5f271bc..41b6d31 100644
--- a/arch/ia64/include/asm/page.h
+++ b/arch/ia64/include/asm/page.h
@@ -41,7 +41,7 @@
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))
 
-#define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
+#define PERCPU_PAGE_SHIFT	18	/* log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
 
 
