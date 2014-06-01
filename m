From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sun, 01 Jun 2014 21:45:13 +0000
Subject: [PATCH] arch: ia64: kernel: patch.c:  Optimization of the Code
Message-Id: <1401659113-17750-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From what I know, AND is faster then modulo.
Not sure if this is worth changing though.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 arch/ia64/kernel/patch.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index 1cf0917..0152455 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -49,7 +49,8 @@ ia64_patch (u64 insn_addr, u64 mask, u64 val)
 	unsigned long shift;
 
 	b0 = b[0]; b1 = b[1];
-	shift = 5 + 41 * (insn_addr % 16); /* 5 bits of template, then 3 x 41-bit instructions */
+	/* 5 bits of template, then 3 x 41-bit instructions */
+	shift = 5 + 41 * (insn_addr & 0xf);
 	if (shift >= 64) {
 		m1 = mask << (shift - 64);
 		v1 = val << (shift - 64);
-- 
1.7.10.4

