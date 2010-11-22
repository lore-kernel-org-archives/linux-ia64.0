From: Toshiyuki Okajima <toshi.okajima@jp.fujitsu.com>
Date: Mon, 22 Nov 2010 03:33:23 +0000
Subject: [PATCH v2] ia64: fix comment bug of ia64_plt_template
Message-Id: <20101122123323.8a848670.toshi.okajima@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi.

I found another comment bug in the same source.
Please fix it.

-------------------------------------------------------------------
From: Toshiyuki Okajima <toshi.okajima@jp.fujitsu.com>

This is a patch which fixes a comment bug in arch/ia64/kernel/module.c:

 212 struct plt_entry {
 213         /* Three instruction bundles in PLT. */
                ^^^^^
 214         unsigned char bundle[2][16];
 215 };
 216 
 217 static const struct plt_entry ia64_plt_template = {
 218         {
 219                 {
 220                         0x04, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0 */
 221                         0x00, 0x00, 0x00, 0x00, 0x00, 0x20, /*       movl gp=TARGET_GP */
 222                         0x00, 0x00, 0x00, 0x60
 223                 },
 224                 {
 225                         0x05, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0 */
 226                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* brl.many gp=TARGET_GP */
                                                                             ^^^^^^^^^^^^
 227                         0x08, 0x00, 0x00, 0xc0
 228                 }
 229         }
 230 };

The correct comment is: 
/* Three instruction bundles in PLT. */ => /* Two instruction bundles in PLT. */
/* brl.many gp=TARGET_GP */ => /* brl.many TARGET_IP */

Signed-off-by: Toshiyuki Okajima <toshi.okajima@jp.fujitsu.com>
---
 arch/ia64/kernel/module.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 1481b0a..8b30b25 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -210,7 +210,7 @@ apply_imm21b (struct module *mod, struct insn *insn, uint64_t val)
 #if USE_BRL
 
 struct plt_entry {
-	/* Three instruction bundles in PLT. */
+	/* Two instruction bundles in PLT. */
  	unsigned char bundle[2][16];
 };
 
@@ -223,7 +223,7 @@ static const struct plt_entry ia64_plt_template = {
 		},
 		{
 			0x05, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0 */
-			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /*	     brl.many gp=TARGET_GP */
+			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /*	     brl.many TARGET_IP */
 			0x08, 0x00, 0x00, 0xc0
 		}
 	}
-- 
1.5.5.6
