From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:56:28 +0000
Subject: [PATCH 0154/1529] Fix typo
Message-Id: <20160521115628.7529-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/include/asm/sal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/sal.h b/arch/ia64/include/asm/sal.h
index e504f38..9b7b9ce 100644
--- a/arch/ia64/include/asm/sal.h
+++ b/arch/ia64/include/asm/sal.h
@@ -787,7 +787,7 @@ ia64_sal_register_physical_addr (u64 phys_entry, u64 phys_addr)
 /*
  * Register software dependent code locations within SAL. These locations are handlers or
  * entry points where SAL will pass control for the specified event. These event handlers
- * are for the bott rendezvous, MCAs and INIT scenarios.
+ * are for the boot rendezvous, MCAs and INIT scenarios.
  */
 static inline s64
 ia64_sal_set_vectors (u64 vector_type,
-- 
2.8.2.534.g1f66975

