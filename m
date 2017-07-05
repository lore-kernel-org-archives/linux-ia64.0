From: Joe Perches <joe@perches.com>
Date: Wed, 05 Jul 2017 20:02:15 +0000
Subject: [PATCH 06/18] ia64: Move inline before return type
Message-Id: <d47074493af80ce12590340294bc49618165c30d.1499284835.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1499284835.git.joe@perches.com>
In-Reply-To: <cover.1499284835.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Make the use of inline like the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/mca.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 79c7c46d7dc1..555b11180156 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -334,7 +334,7 @@ static void ia64_mlogbuf_dump_from_init(void)
 	ia64_mlogbuf_dump();
 }
 
-static void inline
+static inline void
 ia64_mca_spin(const char *func)
 {
 	if (monarch_cpu = smp_processor_id())
-- 
2.10.0.rc2.1.g053435c

