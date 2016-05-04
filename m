From: Matt Fleming <matt@codeblueprint.co.uk>
Date: Wed, 04 May 2016 11:17:50 +0000
Subject: [PATCH 5/5] ia64/unaligned: Silence another GCC warning about an uninitialised variable
Message-Id: <1462360670-27993-6-git-send-email-matt@codeblueprint.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
In-Reply-To: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>

  arch/ia64/kernel/unaligned.c: In function 'ia64_handle_unaligned':
  arch/ia64/kernel/unaligned.c:1385:16: warning: 'u.l' may be used uninitialized in this function [-Wmaybe-uninitialized]
    opcode = (u.l >> IA64_OPCODE_SHIFT) & IA64_OPCODE_MASK;
                ^

Signed-off-by: Matt Fleming <matt@codeblueprint.co.uk>
---
 arch/ia64/kernel/unaligned.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
index e7ae6088350a..7f0d31656b4d 100644
--- a/arch/ia64/kernel/unaligned.c
+++ b/arch/ia64/kernel/unaligned.c
@@ -1378,6 +1378,7 @@ ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 	 * extract the instruction from the bundle given the slot number
 	 */
 	switch (ipsr->ri) {
+	      default:
 	      case 0: u.l = (bundle[0] >>  5); break;
 	      case 1: u.l = (bundle[0] >> 46) | (bundle[1] << 18); break;
 	      case 2: u.l = (bundle[1] >> 23); break;
-- 
2.7.3

