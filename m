From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:56:35 +0000
Subject: [PATCH 0155/1529] Fix typo
Message-Id: <20160521115635.7600-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/include/asm/sn/sn_cpuid.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/sn/sn_cpuid.h b/arch/ia64/include/asm/sn/sn_cpuid.h
index a676dd9..9324173 100644
--- a/arch/ia64/include/asm/sn/sn_cpuid.h
+++ b/arch/ia64/include/asm/sn/sn_cpuid.h
@@ -29,7 +29,7 @@
 
 /*
  *  Definitions of terms (these definitions are for IA64 ONLY. Other architectures
- *  use cpuid/cpunum quite defferently):
+ *  use cpuid/cpunum quite differently):
  *
  *	   CPUID - a number in range of 0..NR_CPUS-1 that uniquely identifies
  *		the cpu. The value cpuid has no significance on IA64 other than
-- 
2.8.2.534.g1f66975

