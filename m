From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Mon, 07 Mar 2016 20:34:54 +0000
Subject: [PATCH] ia64: define ioremap_uc()
Message-Id: <1457382894-13553-1-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <201603062005.lhOBibd1%fengguang.wu@intel.com>
In-Reply-To: <201603062005.lhOBibd1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, mingo@kernel.org, bp@suse.de, "Luis R. Rodriguez" <mcgrof@kernel.org>

All architectures now need ioremap_uc(), ia64 seems defines
this already through its ioremap_nocache() and it already
ensures it *only* uses UC.

Reported-by: 0 day bot
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---

Note, this is actually needed since v4.3 to complete an allyesconfig
compile on ia64, there were others archs that needed this, and this
one just seems to have fallen through the cracks.

 arch/ia64/include/asm/io.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index a865d2a04f75..5de673ac9cb1 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -433,6 +433,7 @@ static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned lo
 	return ioremap(phys_addr, size);
 }
 #define ioremap_cache ioremap_cache
+#define ioremap_uc ioremap_nocache
 
 
 /*
-- 
2.7.2

