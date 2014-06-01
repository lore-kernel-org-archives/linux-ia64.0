From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sun, 01 Jun 2014 21:46:45 +0000
Subject: [PATCH] arch: ia64: kernel: smpboot.c:  Optimization of the Code
Message-Id: <1401659205-17907-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, Paul Gortmaker <paul.gortmaker@windriver.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From what I know, AND is faster then modulo.
Not sure if this is worth changing though.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 arch/ia64/kernel/smpboot.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 547a48d..8d41119 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -237,7 +237,7 @@ get_delta (long *rt, long *master)
 
 	/* average best_t0 and best_t1 without overflow: */
 	tcenter = (best_t0/2 + best_t1/2);
-	if (best_t0 % 2 + best_t1 % 2 = 2)
+	if ((best_t0 & 1) + (best_t1 & 1) = 2)
 		++tcenter;
 	return tcenter - best_tm;
 }
-- 
1.7.10.4

