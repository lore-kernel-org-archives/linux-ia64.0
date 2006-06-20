From: Horms <horms@verge.net.au>
Date: Tue, 20 Jun 2006 03:16:35 +0000
Subject: [PATCH] ia64,kexec: declare ia64_mca_pal_base in mca.h rather than kexec.h
Message-Id: <20060620031632.GA5467@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Kexec adds some code to arch/ia64/kernel/smp.c which needs ia64_mca_pal_base,
  so the kexec patch (actually the kdump patch) declares this
  per-cpu variable in include/asm-ia64/kexec.h.

* ia64_mca_pal_base is defined in arch/ia64/kernel/mca.c, so it
  seems to me that it would make a lot more sense to declare it in
  include/asm-ia64/mca.h.

* This patch moves the declaration.

* This patch is relative to Zou Nan hai's kdump patch which I rediffed
  and sent to linux-ia64 and fastboot on the 8th of June
  http://permalink.gmane.org/gmane.linux.ports.ia64/14320

* This patch will probably need manual merging with another patch to kexec.h
  that I sent yesterday, which related to removing some PTE macros.
  The merge should be trivial, and I'm happy to supply relative diff
  if need be.
  http://permalink.gmane.org/gmane.linux.ports.ia64/14407

Signed-off-by: Horms <horms@tabatha.lab.ultramonkey.org>
---
 include/asm-ia64/kexec.h |    1 -
 include/asm-ia64/mca.h   |    2 ++
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
index d45c03f..add2a73 100644
--- a/include/asm-ia64/kexec.h
+++ b/include/asm-ia64/kexec.h
@@ -20,7 +20,6 @@ #define pte_bits	3
 #define vmlpt_bits	(impl_va_bits - PAGE_SHIFT + pte_bits)
 #define POW2(n)		(1ULL << (n))
 
-DECLARE_PER_CPU(u64, ia64_mca_pal_base);
 const extern unsigned int relocate_new_kernel_size;
 volatile extern long kexec_rendez;
 extern void relocate_new_kernel(unsigned long, unsigned long, 
diff --git a/include/asm-ia64/mca.h b/include/asm-ia64/mca.h
index 9c5389b..75f8ba8 100644
--- a/include/asm-ia64/mca.h
+++ b/include/asm-ia64/mca.h
@@ -23,6 +23,8 @@ #include <asm/mca_asm.h>
 
 #define IA64_MCA_RENDEZ_TIMEOUT		(20 * 1000)	/* value in milliseconds - 20 seconds */
 
+DECLARE_PER_CPU(u64, ia64_mca_pal_base);
+
 typedef struct ia64_fptr {
 	unsigned long fp;
 	unsigned long gp;
-- 
1.4.0

