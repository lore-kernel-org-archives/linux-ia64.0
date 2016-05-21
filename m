From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:55:51 +0000
Subject: [PATCH 0149/1529] Fix typo
Message-Id: <20160521115551.7268-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/include/asm/mca_asm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/mca_asm.h b/arch/ia64/include/asm/mca_asm.h
index 13c1d49..f54ba81 100644
--- a/arch/ia64/include/asm/mca_asm.h
+++ b/arch/ia64/include/asm/mca_asm.h
@@ -73,7 +73,7 @@
  *
  *	5.	Get the physical address corresponding to the virtual address
  *		of the next instruction bundle and put it in iip.
- *		(Using magic numbers 24 and 40 in the deposint instruction since
+ *		(Using magic numbers 24 and 40 in the deposing instruction since
  *		 the IA64_SDK code directly maps to lower 24bits as physical address
  *		 from a virtual address).
  *
-- 
2.8.2.534.g1f66975

